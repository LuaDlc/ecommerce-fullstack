import React, { useState } from 'react';
import { useMutation, gql } from '@apollo/client';
import { GET_PRODUCTS } from './ProductList'; 
import './AddProductForm.css'; 

const ADD_PRODUCT = gql`
  mutation AddProduct($name: String!, $price: Float!, $image: String!) {
    addProduct(name: $name, price: $price, image: $image) {
      id
      name
    }
  }
`;

function AddProductForm() {
  const [name, setName] = useState('');
  const [price, setPrice] = useState('');
  const [image] = useState('https://via.placeholder.com/150');
  
  const [addProduct, { loading }] = useMutation(ADD_PRODUCT, {
    refetchQueries: [{ query: GET_PRODUCTS }] 
  });

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await addProduct({ 
        variables: { 
          name, 
          price: parseFloat(price), 
          image 
        } 
      });
      alert('Produto Adicionado!');
      setName('');
      setPrice('');
    } catch (err) {
      alert('Erro ao adicionar: ' + err.message);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="add-product-container">
      <h2> Novo Produto</h2>
      <div className="form-row">
        <input 
          className="input-field"
          placeholder="Nome do Produto" 
          value={name} 
          onChange={e => setName(e.target.value)} 
        />
        <input 
          className="input-field"
          placeholder="Preço (ex: 50.00)" 
          type="number" 
          value={price} 
          onChange={e => setPrice(e.target.value)} 
        />
      </div>
      <button type="submit" disabled={loading} className="btn-add">
        {loading ? 'Salvando...' : 'Adicionar Produto'}
      </button>
    </form>
  );
}

export default AddProductForm;