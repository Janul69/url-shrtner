const AWS = require('aws-sdk');
const crypto = require('crypto');

const dynamoDB = new AWS.DynamoDB.DocumentClient();
const TABLE_NAME = 'url-shortener';
const BASE_URL = 'https://myapp.com';

function generateShortCode(url, length = 6) {
    const hash = crypto.createHash('md5').update(url + Date.now()).digest('hex');
    return hash.substring(0, length);
}

function isValidUrl(url) {
    try {
      const urlObj = new URL(url);
      return urlObj.protocol === 'http:' || urlObj.protocol === 'https:';
    } catch (err) {
      return false;
    }
}

async function shortCodeExists(shortCode) {
    const params = {
      TableName: TABLE_NAME,
      Key: { shortCode }
    };
  
    try {
      const result = await dynamodb.get(params).promise();
      return !!result.Item;
    } catch (error) {
      console.error('Error checking short code existence:', error);
      return false;
    }
}

async function storeUrl(shortCode, originalUrl, metadata = {}) {
    const timestamp = Math.floor(Date.now() / 1000);
    const expiresAt = timestamp + (30 * 24 * 60 * 60); // 30 days expiration
  
    const params = {
      TableName: TABLE_NAME,
      Item: {
        shortCode,
        originalUrl,
        createdAt: timestamp,
        expiresAt,
        clickCount: 0,
        createdBy: metadata.ip || 'anonymous',
        userAgent: metadata.userAgent || 'unknown'
      }
    };
  
    try {
      await dynamodb.put(params).promise();
      return params.Item;
    } catch (error) {
      console.error('Error storing URL:', error);
      throw error;
    }
}

exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event, null, 2));
  
    // CORS headers
    const headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
      'Access-Control-Allow-Methods': 'POST,OPTIONS'
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
      // Parse request body
      let body;
      try {
        body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
      } catch (parseError) {
        return {
          statusCode: 400,
          headers,
          body: JSON.stringify({
            error: 'Invalid JSON in request body'
          })
        };
      }
  
      const { url, customCode } = body;
  
      // Validate required fields
      if (!url) {
        return {
          statusCode: 400,
          headers,
          body: JSON.stringify({
            error: 'Missing required field: url'
          })
        };
      }
  
      // Validate URL format
      if (!isValidUrl(url)) {
        return {
          statusCode: 400,
          headers,
          body: JSON.stringify({
            error: 'Invalid URL format. Must be a valid HTTP or HTTPS URL.'
          })
        };
      }
  
      // Generate or use custom short code
      let shortCode;
      let attempts = 0;
      const maxAttempts = 5;
  
      if (customCode) {
        // Validate custom code (alphanumeric, 4-10 characters)
        if (!/^[a-zA-Z0-9]{4,10}$/.test(customCode)) {
          return {
            statusCode: 400,
            headers,
            body: JSON.stringify({
              error: 'Custom code must be 4-10 alphanumeric characters'
            })
          };
        }
  
        // Check if custom code is available
        if (await shortCodeExists(customCode)) {
          return {
            statusCode: 409,
            headers,
            body: JSON.stringify({
              error: 'Custom code already in use. Please choose another.'
            })
          };
        }
  
        shortCode = customCode;
      } else {
        // Generate unique short code
        do {
          shortCode = generateShortCode(url);
          attempts++;
  
          if (attempts >= maxAttempts) {
            return {
              statusCode: 500,
              headers,
              body: JSON.stringify({
                error: 'Failed to generate unique short code. Please try again.'
              })
            };
          }
        } while (await shortCodeExists(shortCode));
      }
  
      // Extract metadata
      const metadata = {
        ip: event.requestContext?.identity?.sourceIp,
        userAgent: event.headers?.['User-Agent'] || event.headers?.['user-agent']
      };
  
      // Store in DynamoDB
      const item = await storeUrl(shortCode, url, metadata);
  
      // Return success response
      return {
        statusCode: 201,
        headers,
        body: JSON.stringify({
          success: true,
          shortCode,
          shortUrl: `${BASE_URL}/${shortCode}`,
          originalUrl: url,
          createdAt: item.createdAt,
          expiresAt: item.expiresAt
        })
      };
  
    } catch (error) {
      console.error('Error:', error);
  
      return {
        statusCode: 500,
        headers,
        body: JSON.stringify({
          error: 'Internal server error',
          message: error.message
        })
      };
    }
  };


