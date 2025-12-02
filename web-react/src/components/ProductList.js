import React from 'react';
import { useQuery, gql } from '@apollo/client';
import './ProductList.css'; 

export const GET_PRODUCTS = gql`
  query GetProducts {
    products {
      id
      name
      price
      image
    }
  }
`;

function ProductList() {
  const { loading, error, data } = useQuery(GET_PRODUCTS);

  if (loading) return <p>Carregando produtos...</p>;
  if (error) return <p style={{color: 'red'}}>Erro: {error.message}</p>;

  return (
    <div className="product-list-container">
      <h2>Produtos Atuais</h2>
      <div className="product-grid">
        {data.products.map(p => (
          <div key={p.id} className="product-card">
            <img src={p.image} alt={p.name} className="product-image" />
            <h3 className="product-name">{p.name}</h3>
            <p className="product-price">R$ {p.price}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

export default ProductList;