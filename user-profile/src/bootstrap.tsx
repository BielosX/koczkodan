import React from 'react';
import ReactDOM from 'react-dom/client';
import UserProfile from './UserProfile.tsx';

const rootEl = document.getElementById('root');
if (rootEl) {
  const root = ReactDOM.createRoot(rootEl);
  root.render(
    <React.StrictMode>
      <UserProfile />
    </React.StrictMode>,
  );
}
