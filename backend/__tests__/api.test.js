const request = require('supertest');
const path = require('path');
require('dotenv').config({path: path.resolve(__dirname, '../.env')});

const BASE_URL = 'http://127.0.0.1:5000';

describe('Autenticacao API', () => {
    it('Deve retornar 200 e token ao logar com credenciais corretas', async () => {
        const res = await request(BASE_URL).post('/login').send({
            email: 'teste@email.com',
            password: '123'
        });

        expect(res.statusCode).toEqual(200);
        expect(res.body).toHaveProperty('accessToken');
        expect(res.body).toHaveProperty('refreshToken');
    });

    it('Deve retornar 401 com senha errada', async () => {
        const res = await request(BASE_URL).post('/login').send({email: 'teste@email.com', password: 'wrong_password'});

        expect(res.statusCode).toEqual(401);
    });

    it('Deve bloquear acesso ao graphql sem token', async () => {
        const query = {
            query: "{ products { name } }"

        };

        const res = await request(BASE_URL).post('/graphql').send(query);

        expect(res.statusCode).toEqual(200);
        expect(res.body).toHaveProperty('errors');
        expect(res.body.errors[0].message).toContain('Nao autorizado');
    });
})