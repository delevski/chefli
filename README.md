# Chefli - AI-Powered Recipe Generator

Chefli is an AI-powered recipe generator that creates personalized recipes based on ingredients you have available.

## Features

- Enter ingredients and get AI-generated recipes
- Save and view your recipe history
- Dark/Light theme support
- Multi-language support (English/Hebrew)
- Google Sign-In authentication
- Settings page with privacy policy and terms

## Quick Start

### Prerequisites

- Node.js 20+
- npm 9+

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd chefli

# Install dependencies
npm install
```

### Development

Run both backend and webapp together:

```bash
npm run dev:all
```

This starts:
- Backend: http://localhost:3000
- Webapp: http://localhost:5173

Open http://localhost:5173 in your browser.

### Production Build

```bash
# Build the webapp
npm run build

# Start production server
NODE_ENV=production node backend/server.js
```

## Project Structure

```
chefli/
├── backend/              # Express backend server
│   ├── server.js         # Main server file
│   └── instantdb-proxy.js # InstantDB API proxy
├── src/                  # React webapp source
│   ├── components/       # Reusable components
│   ├── context/          # React context providers
│   ├── pages/            # Page components
│   ├── services/         # API services
│   └── styles/           # CSS styles
├── dist/                 # Production build output
├── .env.development      # Dev environment variables
├── .env.production       # Prod environment variables
└── package.json          # Project configuration
```

## Available Scripts

| Script | Description |
|--------|-------------|
| `npm run dev:all` | Run backend + webapp together |
| `npm run dev` | Run webapp only |
| `npm run dev:backend` | Run backend only |
| `npm run build` | Build for production |
| `npm run preview` | Preview production build |
| `npm run verify:config` | Verify configuration |

## Environment Variables

### Development (`.env.development`)

```bash
VITE_BACKEND_URL=http://localhost:3000
VITE_GOOGLE_CLIENT_ID=your-google-client-id
VITE_INSTANTDB_APP_ID=your-instantdb-app-id
```

### Production (`.env.production`)

```bash
VITE_BACKEND_URL=https://your-production-url.com
VITE_GOOGLE_CLIENT_ID=your-production-google-client-id
VITE_INSTANTDB_APP_ID=your-instantdb-app-id
```

## Deployment

Multiple deployment options are available:

### Docker

```bash
# Build and run
docker build -t chefli .
docker run -p 3000:3000 chefli
```

### Docker Compose

```bash
docker-compose up -d
```

### Vercel

```bash
vercel --prod
```

### Netlify

```bash
netlify deploy --prod
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.

## Documentation

- [DEVELOPMENT.md](DEVELOPMENT.md) - Development setup guide
- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment options
- [ENV_SETUP.md](ENV_SETUP.md) - Environment configuration

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check |
| `/api/users/create` | POST | Create user account |
| `/api/users/find` | POST | Find user by email |
| `/api/users/create-google` | POST | Google sign-in |
| `/api/recipes/generate` | POST | Generate recipe |
| `/api/ocr/extract-text` | POST | OCR text extraction |
| `/api/speech/transcribe` | POST | Audio transcription |

## Tech Stack

- **Frontend**: React 19, Vite, Framer Motion, React Router
- **Backend**: Express.js, Node.js
- **Database**: InstantDB
- **Auth**: Google OAuth 2.0
- **AI**: LangChain (recipe generation)
- **OCR**: Tesseract.js
- **Styling**: CSS with CSS Variables

## License

Private - All rights reserved
