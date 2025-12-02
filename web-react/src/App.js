import React, { useState } from 'react';
import {
  ApolloClient,
  InMemoryCache,
  ApolloProvider,
  createHttpLink // Voltamos a usar createHttpLink na v3, é mais seguro
} from '@apollo/client';

// Importação padrão da v3 (sem classes complexas)
import { setContext } from '@apollo/client/link/context';

import Login from './components/Login';
import AddProductForm from './components/AddProductForm';
import ProductList from './components/ProductList';
import './App.css';

// Configuração do Link HTTP
const httpLink = createHttpLink({
  uri: 'http://localhost:5000/graphql',
});

// Configuração da Autenticação (Simples e funcional na v3)
const authLink = setContext((_, { headers }) => {
  const token = localStorage.getItem('token');
  return {
    headers: {
      ...headers,
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
        <h1>Painel Administrativo</h1>
        
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