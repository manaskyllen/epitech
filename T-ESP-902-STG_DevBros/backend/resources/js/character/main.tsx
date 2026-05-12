import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'
import { MannequinProvider } from './context/MannequinProvider.tsx'
import AuthenticationProvider from './context/AuthenticationProvider.tsx'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <AuthenticationProvider>
      <MannequinProvider>
        <App />
      </MannequinProvider>
    </AuthenticationProvider>
  </StrictMode>,
)
