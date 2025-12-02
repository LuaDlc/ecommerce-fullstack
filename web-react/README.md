# E-commerce Full Stack Ecosystem (Flutter + React + Node.js)

Desenvolvido por [Seu Nome] como projeto de estudo avançado em arquitetura Full Stack. [LinkedIn](www.linkedin.com/in/luana-dias-linhares

) | [GitHub](https://github.com/LuaDlc)

Um ecossistema completo de E-commerce com arquitetura de software escalável, autenticação e simulação pagamentos. O projeto consiste em um **Backend GraphQL/REST**, um **App Mobile (Flutter)** para clientes e um **Painel Web (React)** para administração.

## Destaques Técnicos

- ** Autenticação Silenciosa (Silent Refresh):** Implementação simples de JWT com `Access Token` e `Refresh Token`. O App Mobile possui interceptadores HTTP (Dio) que detectam tokens expirados (401), renovam a sessão automaticamente e retentam a requisição original sem deslogar o usuário.
- ** Pagamentos Reais:** Integração com **Stripe**. O Backend gera `PaymentIntents` seguros e o Frontend mobile finaliza a transação.

- ** API Híbrida (REST + GraphQL):**
  - **REST:** Usado para autenticação segura e webhooks.
  - **GraphQL:** Usado para busca de dados no catálogo de produtos.
- **Segurança:** validação de tokens no lado do servidor.
- **Testes Automatizados (QA):** Suíte de testes de integração no Flutter que valida fluxos críticos, incluindo a "sabotagem" de tokens para garantir a resiliência da autenticação.

## Tech Stack

### Mobile (Flutter)

![Login](./screenshots/login-mobile.png)

- **Gerenciamento de Estado & API:** `Dio` (com Interceptors Customizados), `GraphQL Flutter`.
  ![Home](screenshots/app-produtos.png)
- **Segurança:** `Flutter Secure Storage`.
- **Pagamentos:** `Flutter Stripe`.
  ![Stripe](screenshots/app-pagamento.png)

- **Testes:** `Integration Test`, `Flutter Test`.

### Web Admin (React.js)

![Web](screenshots/web-react.png)

- **Core:** React Hooks, Functional Components.
- **Dados:** `Apollo Client` (Gerenciamento de Cache e Queries).
- **Estilização:** CSS Modules.

### Backend (Node.js)

- **Server:** Express.js + Apollo Server.
- **Auth:** `JsonWebToken` (JWT).
- **Pagamentos:** Stripe SDK.

---

## Como Rodar o Projeto

### Pré-requisitos

- Node.js (v18+)
- Flutter SDK (v3.x)
- Chaves de Teste do Stripe (Crie uma conta gratuita em stripe.com)

### 1. Configurando o Backend

```bash
cd backend
npm install
# Crie um arquivo .env na raiz do backend com as chaves:
# PORT=5000
# STRIPE_SECRET_KEY=sk_test_...
# JWT_SECRET=sua_senha_secreta
# REFRESH_SECRET=sua_senha_refresh
node server.js
```
