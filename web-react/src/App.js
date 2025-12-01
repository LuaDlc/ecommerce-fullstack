import React, { useState } from 'react';
import {
  ApolloClient,
  InMemoryCache,
  ApolloProvider,
  HttpLink
} from '@apollo/client';

import { SetContextLink } from '@apollo/client/link/context';

import Login from './components/Login';
import AddProductForm from './components/AddProductForm';
import ProductList from './components/ProductList';
import './App.css';

const httpLink = new HttpLink({
  uri: 'http://localhost:5000/graphql',
});

const authLink = new SetContextLink((context) => {
  const token = localStorage.getItem('token');
  return {
    headers: {
      ...context.headers,
      authorization: token ? `Bearer ${token}` : "",
    }
  }
});

const client = new ApolloClient({
  link: authLink.concat(httpLink),
  cache: new InMemoryCache()
});

export default function App() {
  const [ isLoggedIn, setIsLoggedIn] = useState(!!localStorage.getItem('token'));

  if(!isLoggedIn) {
    return <Login onLogin={() => setIsLoggedIn(true)} />;
  }
  
  return (
   <ApolloProvider client={client}>
     <div className="app-container">
      <header className='header'>
        <h1>Painel administrativo</h1>
        <button className='btn-logout' onClick={() => {
          localStorage.removeItem('token');
          setIsLoggedIn(false);
        }}>
          Sair
        </button>
      </header>
      <main>
        <AddProductForm/>
        <ProductList/>
      </main>
    </div>
   </ApolloProvider>
  );
}