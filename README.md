# Aplicativo de Encomendas Artesanais

Este projeto é um aplicativo mobile desenvolvido com Flutter, seguindo os princípios de **Clean Architecture** e uma abordagem **Local-First** com SQLite.

## Arquitetura e Tecnologias

- **Flutter**: Framework UI.
- **SQLite (sqflite)**: Persistência local de dados.
- **Clean Architecture**: Separação de preocupações em camadas (Data, Domain, App).
- **TDD (Test-Driven Development)**: Garantia de qualidade e regressão.
- **Dotenv**: Gerenciamento de variáveis de ambiente.

## Estrutura do Projeto

- `lib/app/config`: Configurações globais e variáveis de ambiente.
- `lib/core/database`: Serviço de banco de dados e migrações.
- `lib/core/services`: Serviços de negócio (Autenticação, Pedidos, Pagamentos).
- `lib/features`: Funcionalidades do sistema organizadas por domínio.
- `test`: Testes unitários e de integração.

## Como Executar

1.  Certifique-se de ter o Flutter instalado.
2.  Instale as dependências:
    ```bash
    flutter pub get
    ```
3.  Configure o arquivo `.env` na raiz (baseado no `03-especs.md`). Certifique-se de que `DB_VERSION` está como `2` para garantir o carregamento dos produtos.
4.  Execute o aplicativo:
    ```bash
    flutter run
    ```

## Executando Testes

Para rodar todos os testes automatizados:
```bash
flutter test
```

Para gerar mocks:
```bash
dart run build_runner build
```

## Documentação

Os documentos detalhados de especificação e testes encontram-se na pasta `doc/`:
- `doc/03-especs.md`: Especificações técnicas (Incluindo Vitrine de Produtos).
- `doc/testing.md`: Plano de testes e cenários.

## Telas Principais

- **Vitrine de Produtos Artesanais**: Tela inicial que exibe o catálogo de produtos.
- **Iniciar Pedido**: Fluxo para clientes realizarem novas encomendas.
- **Gerenciar Pedidos**: Controle logístico para atendentes (Produção e Envio).
- **Gerenciar Produtos**: CRUD completo de catálogo para administradores.
- **Gerenciar Atendentes**: Gestão de equipe para administradores.
- **Login e Cadastro**: Fluxos de autenticação.
