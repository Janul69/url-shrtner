const AWS = require('aws-sdk');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const TABLE_NAME = 'url-shortener';
const DEFAULT_REDIRECT = 'https://myapp.com';

/**
 * Get URL from DynamoDB by short code
 * @param {string} shortCode
 * @returns {Promise<object|null>}
 */
async function getUrl(shortCode) {
  const params = {
    TableName: TABLE_NAME,
    Key: { shortCode }
  };

  try {
    const result = await dynamodb.get(params).promise();
    return result.Item || null;
  } catch (error) {
    console.error('Error fetching URL:', error);
    throw error;
  }
}

/**
 * Increment click count for a short code
 * @param {string} shortCode
 */
async function incrementClickCount(shortCode) {
  const params = {
    TableName: TABLE_NAME,
    Key: { shortCode },
    UpdateExpression: 'SET clickCount = if_not_exists(clickCount, :start) + :inc',
    ExpressionAttributeValues: {
      ':inc': 1,
      ':start': 0
    }
  };

  try {
    await dynamodb.update(params).promise();
  } catch (error) {
    console.error('Error incrementing click count:', error);
    // Don't throw - we still want to redirect even if count fails
  }
}

/**
 * Log analytics data (optional - can be extended)
 * @param {string} shortCode
 * @param {object} event
 */
async function logAnalytics(shortCode, event) {
  // Optional: Store detailed analytics in a separate table
  // For now, we just log to CloudWatch
  console.log('Analytics:', {
    shortCode,
    timestamp: new Date().toISOString(),
    ip: event.requestContext?.identity?.sourceIp,
    userAgent: event.headers?.['User-Agent'] || event.headers?.['user-agent'],
    referer: event.headers?.['Referer'] || event.headers?.['referer']
  });
}

/**
 * Main Lambda handler
 */
exports.handler = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));

  // CORS headers
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
    'Access-Control-Allow-Methods': 'GET,OPTIONS'
  };

  // Handle OPTIONS request for CORS
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ message: 'OK' })
    };
  }

  try {
    // Extract short code from path parameters
    const shortCode = event.pathParameters?.shortCode || event.pathParameters?.proxy;

    if (!shortCode) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({
          error: 'Missing short code in URL path'
        })
      };
    }

    // Validate short code format
    if (!/^[a-zA-Z0-9]{4,10}$/.test(shortCode)) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({
          error: 'Invalid short code format'
        })
      };
    }

    // Get URL from DynamoDB
    const urlData = await getUrl(shortCode);

    if (!urlData) {
      return {
        statusCode: 404,
        headers,
        body: JSON.stringify({
          error: 'Short URL not found',
          message: 'The requested short code does not exist or has expired.'
        })
      };
    }

    // Check if URL has expired (optional, if TTL is not set)
    const currentTimestamp = Math.floor(Date.now() / 1000);
    if (urlData.expiresAt && urlData.expiresAt < currentTimestamp) {
      return {
        statusCode: 410,
        headers,
        body: JSON.stringify({
          error: 'Short URL has expired',
          message: 'This short link is no longer active.'
        })
      };
    }

    // Increment click count (async, don't wait)
    incrementClickCount(shortCode).catch(err => 
      console.error('Failed to increment click count:', err)
    );

    // Log analytics (async, don't wait)
    logAnalytics(shortCode, event).catch(err => 
      console.error('Failed to log analytics:', err)
    );

    // Return redirect response
    return {
      statusCode: 301,
      headers: {
        'Location': urlData.originalUrl,
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0'
      },
      body: ''
    };

  } catch (error) {
    console.error('Error:', error);

    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({
        error: 'Internal server error',
        message: 'An error occurred while processing your request.'
      })
    };
  }
};