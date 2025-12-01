import React, { useState } from 'react';
import './Login.css'; // Importando o CSS

function Login({ onLogin }) {
  const [email, setEmail] = useState('teste@email.com');
  const [password, setPassword] = useState('123');

  const handleLogin = async (e) => {
    e.preventDefault();
    try {
      const res = await fetch('http://localhost:5000/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password })
      });
      
      const data = await res.json();
      if (res.ok) {
        localStorage.setItem('token', data.accessToken);
        onLogin();
      } else {
        alert('Erro: ' + data.message);
      }
    } catch (error) {
      alert('Erro de conexão com o servidor');
    }
  };

  return (
    <div className="login-container">
      <form onSubmit={handleLogin} className="login-form">
        <h1>Login Admin</h1>
        <input 
            type="text" 
            className="form-input"
            placeholder="E-mail"
            value={email} 
            onChange={e => setEmail(e.target.value)} 
        />
        <input 
            type="password" 
            className="form-input"
            placeholder="Senha"
            value={password} 
            onChange={e => setPassword(e.target.value)} 
        />
        <button type="submit" className="btn-login">Entrar</button>
      </form>
    </div>
  );
}

export default Login;