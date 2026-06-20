# Plano de Testes - Aplicativo de Encomendas Artesanais

...

## 2. Cenários de Teste por Componente

...

### 2.9 Fluxo de Pedidos (Cliente)
* **CT24 - Criar Pedido**: Validar se um cliente logado consegue criar um pedido e se ele aparece no banco com status `AGUARDANDO_PAGAMENTO`.

### 2.10 Gestão de Pedidos (Atendente)
* **CT25 - Iniciar Produção**: Validar se atendente consegue mudar status para `EM_FABRICACAO`.
* **CT26 - Registrar Envio**: Garantir que o envio exige um código de rastreio e muda status para `ENVIADO`.

### 2.11 Gestão de Catálogo (Admin)
* **CT27 - CRUD Produto**: Testar inserção, edição e remoção de um produto artesanal.
* **CT28 - Restrição Admin**: Garantir que apenas Admin consiga acessar a tela de gestão de produtos.

### 2.12 Gestão de Atendentes (Admin)
* **CT29 - CRUD Atendente**: Testar criação e exclusão de usuários com perfil `ATENDENTE`.

### 2.13 Segurança
* **CT30 - Senha Admin Inicial**: Validar se o Admin consegue logar com a senha "1234".
