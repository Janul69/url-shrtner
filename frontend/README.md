# URL Shortener Frontend

A simple and elegant frontend for the URL Shortener service built with Next.js and Tailwind CSS.

## Features

- 🎨 Clean, modern UI with dark mode support
- ⚡ Fast and responsive
- 📱 Mobile-friendly design
- 🔗 URL shortening
- 📋 One-click copy to clipboard
- ✨ Smooth animations and transitions

## Getting Started

### Development

First, install dependencies:

```bash
npm install
```

Then, run the development server:

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

### Build for Production

Build the static export:

```bash
npm run build
```

This will create an `out/` directory with static files ready for deployment.

## Deploy to S3

### Prerequisites

- AWS CLI configured
- S3 bucket created
- CloudFront distribution (optional, for CDN)

### Deployment Steps

1. **Build the static site:**
   ```bash
   npm run build
   ```

2. **Upload to S3:**
   ```bash
   aws s3 sync out/ s3://your-bucket-name --delete
   ```

3. **Configure S3 bucket for static website hosting:**
   - Go to S3 bucket → Properties → Static website hosting
   - Enable static website hosting
   - Set index document to `index.html`
   - Set error document to `index.html` (for client-side routing)

4. **Set bucket policy (for public access):**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "PublicReadGetObject",
         "Effect": "Allow",
         "Principal": "*",
         "Action": "s3:GetObject",
         "Resource": "arn:aws:s3:::your-bucket-name/*"
       }
     ]
   }
   ```

5. **Optional: Set up CloudFront distribution** for better performance and custom domain

## API Endpoint

The frontend is configured to use the API Gateway endpoint via environment variable.

### Environment Variables

Create a `.env.local` file in the frontend directory:

```bash
# API Gateway Endpoint
NEXT_PUBLIC_API_URL=https://d1v03sauliyrfr.cloudfront.net/api/shorten
```

**Note:** The `NEXT_PUBLIC_` prefix is required for client-side environment variables in Next.js.

### Default Value

If `NEXT_PUBLIC_API_URL` is not set, it defaults to:
- `https://d1v03sauliyrfr.cloudfront.net/api/shorten`

### For Production Build

When building for production, make sure to set the environment variable before building:

```bash
export NEXT_PUBLIC_API_URL=https://d1v03sauliyrfr.cloudfront.net/api/shorten
npm run build
```

Or create a `.env.production` file with the variable.

## Project Structure

```
frontend/
├── app/
│   ├── page.tsx      # Main page component
│   ├── layout.tsx    # Root layout
│   └── globals.css   # Global styles
├── public/           # Static assets
└── out/              # Static export output (generated)
```

## Technologies

- **Next.js 16** - React framework
- **Tailwind CSS 4** - Utility-first CSS
- **TypeScript** - Type safety
- **React 19** - UI library
