#  Ecommerce Fullstack Ecosystem  
**Flutter · React · Node.js · GraphQL · Stripe**

Projeto fullstack desenvolvido por mim com foco em **arquitetura escalável, segurança e integração frontend/backend**.

🔗 LinkedIn: https://www.linkedin.com/in/luana-dias-linhares

---

##  Visão Geral

Este projeto representa um **ecossistema completo de ecommerce**, composto por:

-  **App Mobile (Flutter)** para clientes
-  **Painel Web (React)** para administração
-  **Backend Node.js** com API híbrida (**REST + GraphQL**)
-  **Pagamentos reais** via Stripe

O objetivo principal não é  **demonstrar decisões arquiteturais, segurança e robustez de autenticação** em um ambiente fullstack realista.

---

##  Destaques Técnicos

###  Autenticação com Silent Refresh
- Implementação de **JWT com Access Token + Refresh Token**
- Interceptors HTTP no Flutter (Dio) detectam `401`
- Renovação automática de sessão
- Reexecução da requisição original **sem deslogar o usuário**



---

###  Pagamentos Reais com Stripe
- Backend gera **PaymentIntents seguros**
- Frontend mobile finaliza a transação
- Comunicação segura entre cliente, backend e Stripe

   ![Stripe](screenshots/app-pagamento.png)

---

### API Híbrida (REST + GraphQL)
- **REST**
  - Autenticação
  - Webhooks
- **GraphQL**
  - Catálogo de produtos
  - Queries e mutations otimizadas
 
     ![APitestes](screenshots/node-test.png)

---

###  Testes Automatizados
- Testes de integração no Flutter
- Validação de fluxos críticos
- **Sabotagem proposital de tokens** para validar resiliência da autenticação


---

##  Tech Stack

###  Mobile — Flutter
- HTTP & API: **Dio (Interceptors customizados)**, GraphQL Flutter
- Segurança: Flutter Secure Storage
- Pagamentos: Flutter Stripe
- Testes: Integration Test, Flutter Test

![testesintegracao](screenshots/testes-integracao-flutter.png)

---



###  Web Admin — React
- Core: React Hooks, Functional Components
- Dados: Apollo Client
- Estilização: CSS Modules

 ![Web](screenshots/web-react.png)

---

###  Backend — Node.js
- Server: Express.js + Apollo Server
- Autenticação: JWT
- Pagamentos: Stripe SDK
- Persistência: Mock / In-memory (foco em arquitetura)

---

##  Arquitetura Geral

```mermaid
flowchart TB
subgraph Client Side [" Client Side"]
    Mobile[" Mobile App (Flutter)"]
    Web[" Web Admin (React)"]
end

subgraph Server Side [" Backend (Node.js)"]
    API[" API Gateway / Express"]
    Auth[" Auth Service (REST + JWT)"]
    GQL[" GraphQL Service"]
    DB[" Database (Mock)"]
end

Stripe[" Stripe"]

Mobile --> Auth
Mobile --> GQL
Web --> Auth
Web --> GQL
GQL --> DB
Auth --> DB
GQL --> Stripe
