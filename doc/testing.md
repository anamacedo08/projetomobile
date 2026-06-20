# Plano de Testes - Aplicativo de Encomendas Artesanais

Este documento descreve a estratégia de testes automatizados, seguindo a metodologia **TDD (Test-Driven Development)** para garantir a integridade das regras de negócio e evitar regressões.

---

## 1. Estratégia de Testes

### 1.1 TDD First
O desenvolvimento deve seguir o ciclo:
1. **RED**: Escrever um teste que falha para a funcionalidade desejada.
2. **GREEN**: Implementar o código mínimo necessário para o teste passar.
3. **REFACTOR**: Melhorar o código mantendo a passagem nos testes.

### 1.2 Níveis de Teste
*   **Unitários**: Foco em lógica isolada (Services, UseCases, Models). Uso intenso de mocks.
*   **Integração**: Validação da persistência (SQLite) e interação entre componentes.
*   **Contrato**: Validação de chamadas externas (Gateways de Pagamento).

---

## 2. Cenários de Teste por Componente

### 2.1 Configuração de Ambiente (`EnvConfig`)
*   **CT01 - Inicialização com Sucesso**: Validar se variáveis como `DB_NAME` e `DB_VERSION` são carregadas corretamente do `.env`.
*   **CT02 - Fallback de Valores**: Garantir que valores padrão sejam usados quando chaves opcionais estiverem ausentes.
*   **CT03 - Erro de Arquivo Ausente**: Validar comportamento do sistema quando o arquivo `.env` não é encontrado.

### 2.2 Banco de Dados (`DatabaseService`)
*   **CT04 - Criação de Tabelas**: Verificar se as tabelas `usuarios` e `pedidos` existem após a inicialização.
*   **CT05 - Injeção de Admin**: Confirmar que o usuário administrador inicial é inserido no banco com as credenciais padrão.
*   **Prioridade**: Crítica. Sem banco inicializado, o app não opera (Local-First).

### 2.3 Autenticação (`AuthService`)
*   **CT06 - Login Válido**: Validar sucesso ao informar e-mail e senha corretos (comparação de Hash SHA-256).
*   **CT07 - Login Inválido**: Garantir falha ao errar credenciais.
*   **CT08 - Permissão de Administrador**: Testar se apenas usuários com perfil `ADMINISTRADOR` conseguem cadastrar novos atendentes.
*   **Mocks**: `DatabaseService`.

### 2.4 Gestão de Pedidos (`OrderService`)
*   **CT09 - Fluxo de Fabricação**: Validar se o status muda para `EM_FABRICACAO` apenas se estiver em `AGUARDANDO_INICIO`.
*   **CT10 - Registro de Envio**: Verificar se o código de rastreio é salvo e status muda para `ENVIADO`.
*   **CT11 - Restrição de Perfil**: Garantir que `CLIENTE` não consiga alterar status de fabricação.

### 2.5 Pagamentos (`PaymentService`)
*   **CT12 - Sucesso no Pagamento**: Simular retorno HTTP 200 do Gateway e validar atualização do pedido para `AGUARDANDO_INICIO`.
*   **CT13 - Falha no Gateway**: Validar que o pedido permanece em `AGUARDANDO_PAGAMENTO` se o pagamento for recusado.
*   **Mocks**: `http.Client` para interceptar requisições externas.

### 2.6 Cadastro de Clientes (`RegisterClientUseCase`)
*   **CT14 - E-mail Duplicado**: Impedir cadastro de novos usuários com e-mail já existente no banco.
*   **CT15 - Validação de Campos**: Garantir que nome, e-mail e senha sejam obrigatórios.

---

## 3. Dependências de Teste

As seguintes ferramentas foram configuradas no `pubspec.yaml`:

*   **flutter_test**: Framework base de testes do Flutter.
*   **mockito**: Criação de objetos simulados (Mocks).
*   **sqflite_common_ffi**: Execução de SQLite em ambiente de testes unitários (Desktop).
*   **http**: Utilizado com `MockClient` para testes de rede.

---

## 4. Guia de Execução

Para executar todos os testes automatizados, utilize o comando:

```bash
flutter test
```

Para gerar cobertura de testes:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 5. Matriz de Mocks Recomendada

| Classe Testada | Dependência Mockada | Motivo |
| :--- | :--- | :--- |
| `AuthService` | `DatabaseService` | Isolar lógica de hash da persistência física. |
| `PaymentService` | `http.Client` | Evitar chamadas reais à API de pagamento. |
| `NotificationService` | Push Provider SDK | Simular recebimento de mensagens sem hardware real. |
| `OrderService` | `DatabaseService` | Validar transições de estado sem IO de disco. |
