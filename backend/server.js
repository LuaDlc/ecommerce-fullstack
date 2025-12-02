require('dotenv').config();
console.log('JWT_SECRET carregado:', process.env.JWT_SECRET);

const express = require('express');
const { ApolloServer, gql} = require('apollo-server-express');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const Stripe = require('stripe');

const PORT = process.env.PORT || 4000;
const JWT_SECRET = process.env.JWT_SECRET;
const REFRESH_SECRET =process.env.REFRESH_SECRET;
const STRIPE_KEY = process.env.STRIPE_SECRET_KEY;

if (!JWT_SECRET || !STRIPE_KEY) {
    console.error("ERRO CRÍTICO: Variáveis do .env não foram carregadas!");
    process.exit(1); 
}

const stripe = Stripe(STRIPE_KEY);


// dados mockados
const users = [
    { id: 1, email: "teste@email.com", password: "123", name: "dev junior"}

];
let refreshTokens = [];

const mockProducts = [
  { id: '1', name: 'Notebook Gamer', price: 5000.0,  image: 'https://via.placeholder.com/150' },
  { id: '2', name: 'Teclado Mecânico', price: 350.0,  image: 'https://via.placeholder.com/150'},
  { id: '3', name: 'Monitor 144hz', price: 1200.0, image: 'https://via.placeholder.com/150' },
];

let mockCart = {
    userId: 1,
    items: [
        { productId: '1', quantity: 1},
        { productId: '2', quantity: 2},
    ]
};

const typeDefs = gql`
  type Product { id: ID!, name: String!, price: Float!, image: String }
  type CartItem { product: Product!, quantity: Int! }
  type Cart { items: [CartItem]!, total: Float! }
  
  type Query { 
    products: [Product]
    myCart: Cart 
  }

  # --- NOVO: Permite alterar dados ---
  type Mutation {
    addProduct(name: String!, price: Float!, image: String!): Product
  }
`;


//resolvers do grapql
const resolvers = {
  Query: {
    products: (parent, args, context) => {
      if (!context.user) throw new Error('Nao autorizado!');
      return mockProducts; 
    },
    myCart: (parent, args, context) => {
      if (!context.user) throw new Error('Nao autorizado!');
      return mockCart;
    },
  },
  
  Mutation: {
    addProduct: (_, { name, price, image }, context) => {
      if (!context.user) throw new Error('Nao autorizado! Faça login.');
      
      const newProduct = {
        id: String(mockProducts.length + 1), // Gera ID simples
        name,
        price,
        image
      };
      
      mockProducts.push(newProduct); // Salva na memória
      return newProduct;
    }
  },
  Cart: {
    items: (parent) => parent.items,
    total: (parent) => parent.items.reduce((acc, item) => {
        const p = mockProducts.find(prod => prod.id === item.productId);
        return acc + (p ? p.price * item.quantity : 0);
    }, 0)
  },
  CartItem: {
    product: (parent) => mockProducts.find(p => p.id === parent.productId)
  }
};

async function startServer() {
    const app = express();

    //middlewares basicos
    app.use(cors());
    app.use((req, res, next) => {
        if (req.originalUrl === '/graphql') {
            next();
        } else {
            express.json()(req, res, next);
        }
    });

    /// REST = AUTENTICACAO
    app.post('/login', (req, res) => {
        const { email, password} = req.body;
        const user = users.find(u => u.email === email && u.password === password);

        if(!user) return res.status(401).json({message: 'Credenciais invalidas'});

        const accessToken = jwt.sign({userId: user.id}, JWT_SECRET, { expiresIn: '10s'});
        const refreshToken = jwt.sign({userId: user.id}, REFRESH_SECRET, {expiresIn: '7d'});

        refreshTokens.push(refreshToken); //salva refresh token

        res.json({ accessToken, refreshToken});
    });

    //rota de refreshtoken-renova o refreshtoken
    app.post('/refresh-token', (req, res) => {
        const { refreshToken} = req.body;

        if (!refreshToken) return res.sendStatus(401);
        if (!refreshTokens.includes(refreshToken)) return res.sendStatus(403); //quando o token nao existe na lista
        jwt.verify(refreshToken, REFRESH_SECRET, (err, user) => {
            if (err) return res.sendStatus(403);

            //gera novo access token
            const accessToken = jwt.sign({ userId: user.userId}, JWT_SECRET, {expiresIn: '5h'});
            res.json({accessToken});
        });
    });

    

    //rota de logout
    app.post('/logout', (req, res) => {
        const { refreshToken } = req.body;

        refreshTokens = refreshTokens.filter(token => token !== refreshToken);

        res.status(200).json({message: "Logout realizado e token invalidado"});
    });

    app.post('/create-payment-intent', async (req, res) => {
        try {
            const paymentIntent = await stripe.paymentIntents.create({
                amount: 5000,
                currency: 'brl',
                automatic_payment_methods: {
                    enabled: true
                },
            });
            console.log("Sucesso! Client Secret gerado.");
            res.json({clientSecret: paymentIntent.client_secret,});
        } catch (e) {
            console.log('Erro stripe:', e.message);
            res.status(400).json({error: e.message });
            
        }
    });

    ///graphql - dados

    const server = new ApolloServer({
        typeDefs,
        resolvers,
        context: ({ req}) => {
            const token = req.headers.authorization || '';
            console.log('header recebido:', token);
            try {
                if (token) {
                    const actualToken = token.split(' ')[1].trim().replace(/"/g, ''); //remove o "bearer"
                    if(!actualToken) return { user: null };

                    const user = jwt.verify(actualToken, JWT_SECRET);
                    console.log('Token valido! usuario:', user.userId);
                    return { user }; 
                }
            } catch (e) {
                //token invalido ou expirado => contex.user sera null
                console.log('Erro ao verificar token:', e.message);
            }
            return { user: null};
        }
    });
    await server.start();
    server.applyMiddleware({ app });


    //inicia o servidor
    app.listen(PORT, '0.0.0.0', () => {
        console.log(`Server rodando em http://localhost:${PORT}`);
        console.log(`REST Auth: http://localhost:${PORT}/login`);
        console.log(`GraphQL: http://localhost:${PORT}/graphql`);
    });
}

startServer();
