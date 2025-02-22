import React from 'react';
import ReactDOM from 'react-dom/client';
import Payments from './Payments.tsx';

const rootEl = document.getElementById('root');
if (rootEl) {
  const root = ReactDOM.createRoot(rootEl);
  root.render(
    <React.StrictMode>
      <Payments />
    </React.StrictMode>,
  );
}