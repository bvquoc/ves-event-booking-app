# VES Booking Admin Portal

A modern, simple admin portal for managing the VES Booking event system.

## Features

- **User Management**: Create, update, and delete users
- **Event Management**: View and manage events
- **Role & Permission Management**: Manage roles and permissions
- **Venue Management**: View venue information
- **Authentication**: Secure JWT-based authentication
- **Responsive Design**: Works on desktop and mobile devices

## Tech Stack

- **Vite**: Fast build tool and dev server
- **React 18**: UI library
- **TypeScript**: Type safety
- **React Router**: Client-side routing
- **shadcn/ui**: Beautiful, accessible UI components
- **Tailwind CSS**: Utility-first CSS framework
- **Axios**: HTTP client
- **date-fns**: Date formatting

## Getting Started

### Prerequisites

- Node.js 18+ and npm

### Installation

1. Install dependencies:
```bash
npm install
```

2. Create a `.env` file (copy from `.env.example`):
```bash
cp .env.example .env
```

3. Update `.env` with your API base URL:
```
VITE_API_BASE_URL=http://localhost:8080/api
```

### Development

Start the development server:
```bash
npm run dev
```

The app will be available at `http://localhost:5173`

### Build

Build for production:
```bash
npm run build
```

The built files will be in the `dist` directory.

### Preview Production Build

Preview the production build:
```bash
npm run preview
```

## Project Structure

```
src/
├── components/       # Reusable components
│   ├── ui/          # shadcn/ui components
│   ├── Layout.tsx   # Main layout with sidebar
│   └── ProtectedRoute.tsx
├── contexts/        # React contexts
│   └── AuthContext.tsx
├── lib/             # Utilities and API client
│   ├── api.ts       # API client and types
│   └── utils.ts     # Utility functions
├── pages/           # Page components
│   ├── Login.tsx
│   ├── Users.tsx
│   ├── Events.tsx
│   ├── Roles.tsx
│   ├── Permissions.tsx
│   └── Venues.tsx
├── App.tsx          # Main app component with routing
├── main.tsx         # Entry point
└── index.css        # Global styles
```

## API Integration

The admin portal integrates with the VES Booking API. All API calls are handled through the `apiClient` in `src/lib/api.ts`. The API client automatically:

- Adds JWT tokens to requests
- Handles authentication errors
- Provides TypeScript types for all API responses

## Authentication

The app uses JWT tokens stored in localStorage. After login, the token is automatically included in all API requests. The token is cleared on logout or when a 401 error is received.

## Development Tips

- The UI uses shadcn/ui components which are simple, customizable React components
- All API types are defined in `src/lib/api.ts` based on the OpenAPI specification
- The layout is responsive with a collapsible sidebar on mobile
- Protected routes automatically redirect to login if not authenticated

## License

MIT

