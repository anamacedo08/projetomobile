As especificações estão organizadas conforme a estrutura de diretórios e os padrões de projeto do seu **Aplicativo de Encomendas Artesanais** definidos (*Clean Architecture*, abordagem *Local-First* com SQLite e controle transacional).

---

### `lib/app/config/env_config.dart`

* **ação**: criar
* **descrição**: Carrega, valida e expõe de forma tipada e centralizada as variáveis de ambiente recuperadas do arquivo `.env`.
* **pseudocódigo**:

```
CLASSE EnvConfig {
    DECLARAR ESTÁTICO APP_ENV: Texto
    DECLARAR ESTÁTICO DB_NAME: Texto
    DECLARAR ESTÁTICO DB_VERSION: Inteiro
    ...
}
```

---

### `lib/core/database/database_service.dart`

* **ação**: criar/atualizar
* **descrição**: Camada singleton responsável pela inicialização física do SQLite, execução de scripts de migração e injeção de dados.
* **Injeção de Admin**: A senha do administrador padrão deve ser "1234" (armazenada como Hash SHA-256).

---

### Gestão de Pedidos (Fluxo do Cliente)

* **Funcionalidade**: Iniciar Pedido.
* **Acesso**: Botão na Vitrine ou Menu Lateral.
* **Ação**: Selecionar produtos, informar detalhes de customização e endereço.
* **Persistência**: Criar registro na tabela `pedidos` com status `AGUARDANDO_PAGAMENTO`.

---

### Gestão de Pedidos (Fluxo do Atendente)

* **Funcionalidade**: Atendimento e Logística.
* **Ação 1 (Produção)**: Mudar status para `EM_FABRICACAO`.
* **Ação 2 (Envio)**: Mudar status para `ENVIADO` e anexar obrigatoriamente um Código de Rastreio.

---

### Gestão do Sistema (Fluxo do Administrador)

* **CRUD de Produtos**:
    * **Cadastrar**: Novo produto com nome, descrição, imagem e preço.
    * **Alterar**: Atualizar dados de produtos existentes.
    * **Excluir**: Remover produto do catálogo.
* **CRUD de Atendentes**:
    * **Cadastrar**: Novo usuário com perfil `ATENDENTE`.
    * **Alterar**: Atualizar dados de atendentes.
    * **Excluir**: Remover atendentes do sistema.

---

### Menu de Funcionalidades (`lib/features/navigation/presentation/widgets/app_menu_drawer.dart`)

* **Itens Dinâmicos**:
    * **Público**: Vitrine, Entrar, Criar Conta.
    * **Cliente**: Vitrine, Meus Pedidos, Iniciar Pedido, Perfil, Sair.
    * **Atendente**: Vitrine, Gerenciar Pedidos, Perfil, Sair.
    * **Administrador**: Vitrine, Gerenciar Produtos, Gerenciar Atendentes, Perfil, Sair.

---

### Telas Adicionais

* **`lib/features/orders/presentation/screens/create_order_screen.dart`**: Formulário de encomenda.
* **`lib/features/orders/presentation/screens/manage_orders_screen.dart`**: Lista de pedidos para atendentes.
* **`lib/features/admin/presentation/screens/manage_products_screen.dart`**: Lista e formulário CRUD de produtos.
* **`lib/features/admin/presentation/screens/manage_attendants_screen.dart`**: Lista e formulário CRUD de atendentes.
