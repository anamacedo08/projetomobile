As especificações estão organizadas conforme a estrutura de diretórios e os padrões de projeto do seu **Aplicativo de Encomendas Artesanais** definidos (*Clean Architecture*, abordagem *Local-First* com SQLite e controle transacional).

---

### `lib/app/config/env_config.dart`

* **ação**: criar
* **descrição**: Carrega, valida e expõe de forma tipada e centralizada as variáveis de ambiente recuperadas do arquivo `.env` configurado dentro do contêiner Docker.
* **pseudocódigo**:

```
CLASSE EnvConfig {
    DECLARAR ESTÁTICO APP_ENV: Texto
    DECLARAR ESTÁTICO DB_NAME: Texto
    DECLARAR ESTÁTICO DB_VERSION: Inteiro
    DECLARAR ESTÁTICO GITHUB_SYNC_TOKEN: Texto
    DECLARAR ESTÁTICO PAYMENT_GATEWAY_KEY: Texto
    DECLARAR ESTÁTICO PUSH_PROVIDER_CONFIG: Texto

    FUNÇÃO ESTÁTICA inicializar(mapaVariaveis: Mapa<Texto, Dinâmico>) {
        SE mapaVariaveis FOR NULO OU mapaVariaveis.estaVazio() ENTRÃO
            LANÇAR ERRO("Configurações de ambiente ausentes.")
        FIM_SE

        APP_ENV = mapaVariaveis.obterOuPadrao("APP_ENV", "development")
        DB_NAME = mapaVariaveis.obterOuPadrao("DB_NAME", "artesanal.db")
        DB_VERSION = ConverterParaInteiro(mapaVariaveis.obterOuPadrao("DB_VERSION", 1))
        GITHUB_SYNC_TOKEN = mapaVariaveis.obterOuPadrao("GITHUB_SYNC_TOKEN", "")
        PAYMENT_GATEWAY_KEY = mapaVariaveis.obterOuPadrao("PAYMENT_GATEWAY_KEY", "")
        PUSH_PROVIDER_CONFIG = mapaVariaveis.obterOuPadrao("PUSH_PROVIDER_CONFIG", "")
    }
}

```

---

### `lib/core/database/database_service.dart`

* **ação**: criar
* **descrição**: Camada singleton responsável pela inicialização física do SQLite no dispositivo móvel, execução de scripts de migração de dados e injeção controlada do Administrador Inicial do ecossistema.
* **pseudocódigo**:

```
CLASSE DatabaseService {
    DECLARAR INSTANCIA_UNICA: DatabaseService
    DECLARAR conexaoBanco: SQLiteConnection

    FUNÇÃO ESTÁTICA obterInstancia(): DatabaseService {
        SE INSTANCIA_UNICA FOR NULO ENTRÃO
            INSTANCIA_UNICA = NOVA DatabaseService()
        FIM_SE
        RETORNAR INSTANCIA_UNICA
    }

    FUNÇÃO assincrona inicializarBanco() {
        CaminhoFisico = ObterCaminhoDiretorioLocal() + "/" + EnvConfig.DB_NAME
        conexaoBanco = ABRIR_BANCO_SQLITE(
            caminho: CaminhoFisico,
            versao: EnvConfig.DB_VERSION,
            aoCriar: executarEsquemaInicial,
            aoAtualizar: executarMigracoes
        )
    }

    FUNÇÃO executarEsquemaInicial(db: SQLiteConnection) {
        db.executarSQL("CREATE TABLE usuarios (id TEXT PRIMARY KEY, nome TEXT, email TEXT, senha_hash TEXT, perfil TEXT)")
        db.executarSQL("CREATE TABLE pedidos (id TEXT PRIMARY KEY, cliente_id TEXT, detalhes TEXT, status TEXT, endereco TEXT, codigo_rastreio TEXT, valor REAL, data_criacao TEXT)")
        
        // Injeção estrita e determinística do Administrador Inicial
        IdAdmin = GerarUUIDV4()
        SenhaHashAdmin = CriptografarSHA256("AdminArtesanal2026!")
        db.executarSQL("INSERT INTO usuarios (id, nome, email, senha_hash, perfil) VALUES (?, ?, ?, ?, ?)", 
                       [IdAdmin, "Administrador Inicial", "admin@artesanal.com", SenhaHashAdmin, "ADMINISTRADOR"])
    }

    FUNÇÃO executarMigracoes(db: SQLiteConnection, versaoAntiga: Inteiro, versaoNova: Inteiro) {
        // Bloco condicional para atualizações granulares de tabelas conforme evolução do esquema
    }
}

```

---

### `lib/core/services/auth_service.dart`

* **ação**: criar
* **descrição**: Centraliza as operações de validação de sessão em cache local, geração de tokens lógicos de acesso e barramento de segurança para criação de novos Atendentes exclusiva por Administradores.
* **pseudocódigo**:

```
CLASSE AuthService {
    DECLARAR dbService: DatabaseService
    DECLARAR usuarioLogado: Usuario

    CONSTRUTOR() {
        dbService = DatabaseService.obterInstancia()
    }

    FUNÇÃO assincrona autenticar(email: Texto, senhaPura: Texto): Booleano {
        HashVerificacao = CriptografarSHA256(senhaPura)
        ResultadoQuery = dbService.conexaoBanco.consultar("SELECT * FROM usuarios WHERE email = ? AND senha_hash = ?", [email, HashVerificacao])
        
        SE ResultadoQuery.tamanho > 0 ENTRÃO
            usuarioLogado = Usuario.mapearDeObjeto(ResultadoQuery[0])
            RETORNAR Verdadeiro
        FIM_SE
        RETORNAR Falso
    }

    FUNÇÃO assincrona cadastrarAtendente(nome: Texto, email: Texto, senhaPura: Texto) {
        SE usuarioLogado FOR NULO OU usuarioLogado.perfil != "ADMINISTRADOR" ENTRÃO
            LANÇAR ERRO("Acesso negado: Operação exclusiva para administradores.")
        FIM_SE

        VerificarEmail = dbService.conexaoBanco.consultar("SELECT id FROM usuarios WHERE email = ?", [email])
        SE VerificarEmail.tamanho > 0 ENTRÃO
            LANÇAR ERRO("Este e-mail já possui cadastro associado.")
        FIM_SE

        NovoId = GerarUUIDV4()
        HashSenha = CriptografarSHA256(senhaPura)
        dbService.conexaoBanco.executar("INSERT INTO usuarios (id, nome, email, senha_hash, perfil) VALUES (?, ?, ?, ?, 'ATENDENTE')", 
                                         [NovoId, nome, email, HashSenha])
    }
}

```

---

### `lib/core/services/order_service.dart`

* **ação**: criar
* **descrição**: Orquestra o ciclo de vida transacional das encomendas artesanais, validando regras de transições de estado permitidas a cada papel do sistema.
* **pseudocódigo**:

```
CLASSE OrderService {
    DECLARAR dbService: DatabaseService

    CONSTRUTOR() {
        dbService = DatabaseService.obterInstancia()
    }

    FUNÇÃO assincrona iniciarFabricacaoManual(pedidoId: Texto, atendenteLogado: Usuario) {
        SE atendenteLogado.perfil != "ATENDENTE" ENTRÃO
            LANÇAR ERRO("Operação restrita para perfis do tipo Atendente.")
        FIM_SE

        Pedido = dbService.conexaoBanco.consultar("SELECT status FROM pedidos WHERE id = ?", [pedidoId])
        SE Pedido.tamanho == 0 OU Pedido[0]["status"] != "AGUARDANDO_INICIO" ENTRÃO
            LANÇAR ERRO("O pedido deve estar sob o status AGUARDANDO_INICIO para iniciar a fabricação manual.")
        FIM_SE

        dbService.conexaoBanco.executar("UPDATE pedidos SET status = 'EM_FABRICACAO' WHERE id = ?", [pedidoId])
    }

    FUNÇÃO assincrona registrarEnvioLogistico(pedidoId: Texto, dadosEnvio: Texto, atendenteLogado: Usuario) {
        SE atendenteLogado.perfil != "ATENDENTE" ENTRÃO
            LANÇAR ERRO("Operação restrita para perfis do tipo Atendente.")
        FIM_SE

        Pedido = dbService.conexaoBanco.consultar("SELECT status FROM pedidos WHERE id = ?", [pedidoId])
        SE Pedido.tamanho == 0 OU Pedido[0]["status"] != "EM_FABRICACAO" ENTRÃO
            LANÇAR ERRO("Não é possível despachar um pedido que não esteja sob o status EM_FABRICACAO.")
        FIM_SE

        dbService.conexaoBanco.executar("UPDATE pedidos SET status = 'ENVIADO', codigo_rastreio = ? WHERE id = ?", [dadosEnvio, pedidoId])
    }
}

```

---

### `lib/core/services/payment_service.dart`

* **ação**: criar
* **descrição**: Isola a comunicação com a API Key de faturamento externo, atualizando a persistência local imediatamente após a conclusão da liquidação do pedido no app.
* **pseudocódigo**:

```
CLASSE PaymentService {
    DECLARAR dbService: DatabaseService

    CONSTRUTOR() {
        dbService = DatabaseService.obterInstancia()
    }

    FUNÇÃO assincrona processarPagamentoApp(pedidoId: Texto, tokenCartao: Texto): Booleano {
        ChaveGateway = EnvConfig.PAYMENT_GATEWAY_KEY
        DadosPedido = dbService.conexaoBanco.consultar("SELECT valor FROM pedidos WHERE id = ?", [pedidoId])
        
        SE DadosPedido.tamanho == 0 ENTRÃO
            LANÇAR ERRO("Pedido inexistente.")
        FIM_SE
        
        ValorTransacao = DadosPedido[0]["valor"]
        ResultadoGateway = DISPARAR_REQUISICAO_HTTP_POST(
            url: "https://api.gateway.com/v1/charge",
            headers: {"Authorization": ChaveGateway},
            body: {"amount": ValorTransacao, "card_token": tokenCartao, "reference_id": pedidoId}
        )

        SE ResultadoGateway.statusCode == 200 E ResultadoGateway.body.status == "PAID" ENTRÃO
            dbService.conexaoBanco.executar("UPDATE pedidos SET status = 'AGUARDANDO_INICIO' WHERE id = ?", [pedidoId])
            RETORNAR Verdadeiro
        FIM_SE

        RETORNAR Falso
    }
}

```

---

### `lib/core/services/notification_service.dart`

* **ação**: criar
* **descrição**: Mapeia o token de notificação local do dispositivo móvel e escuta transições do sistema operacional em primeiro e segundo plano para exibir atualizações de pedidos ao cliente.
* **pseudocódigo**:

```
CLASSE NotificationService {
    DECLARAR pushProviderConfigPath: Texto

    CONSTRUTOR() {
        pushProviderConfigPath = EnvConfig.PUSH_PROVIDER_CONFIG
    }

    FUNÇÃO assincrona vincularTokenDispositivo(usuarioId: Texto) {
        TokenGerado = ExecutarHandshakeProvedorPush(pushProviderConfigPath)
        SE TokenGerado != NULO ENTRÃO
            // Atualiza localmente a referência do aparelho para recebimento direcionado
            DatabaseService.obterInstancia().conexaoBanco.executar(
                "UPDATE usuarios SET push_token = ? WHERE id = ?", [TokenGerado, usuarioId]
            )
        FIM_SE
    }

    FUNÇÃO inicializarOuvintesDeNotificacao() {
        ConfigurarCallbackMensagemEntrada((dadosMensagem) -> {
            MostrarAlertaNotificacaoUI(
                titulo: dadosMensagem.titulo,
                corpo: dadosMensagem.mensagem
            )
        })
    }
}

```

---

### `lib/features/auth/domain/usecases/register_client_usecase.dart`

* **ação**: criar
* **descrição**: Caso de uso focado no fluxo isolado de autocadastro público executado de forma síncrona/assíncrona por novos clientes.
* **pseudocódigo**:

```
CLASSE RegisterClientUseCase {
    DECLARAR dbService: DatabaseService

    CONSTRUTOR() {
        dbService = DatabaseService.obterInstancia()
    }

    FUNÇÃO assincrona executar(nome: Texto, email: Texto, senhaPura: Texto, enderecoPadrao: Texto) {
        SE nome.estaVazio() OU email.estaVazio() OU senhaPura.estaVazio() ENTRÃO
            LANÇAR ERRO("Todos os campos obrigatórios devem ser preenchidos.")
        FIM_SE

        EmailsCadastrados = dbService.conexaoBanco.consultar("SELECT id FROM usuarios WHERE email = ?", [email])
        SE EmailsCadastrados.tamanho > 0 ENTRÃO
            LANÇAR ERRO("O e-mail informado já está em uso por outro usuário.")
        FIM_SE

        NovoClienteId = GerarUUIDV4()
        HashSenha = CriptografarSHA256(senhaPura)

        dbService.conexaoBanco.executar(
            "INSERT INTO usuarios (id, nome, email, senha_hash, perfil) VALUES (?, ?, ?, ?, 'CLIENTE')",
            [NovoClienteId, nome, email, HashSenha]
        )
    }
}

```

---

### `lib/features/orders/domain/usecases/send_order_usecase.dart`

* **ação**: criar
* **descrição**: Insere uma nova solicitação de encomenda de produto artesanal personalizado preenchida com as diretivas logísticas do cliente logado.
* **pseudocódigo**:

```
CLASSE SendOrderUseCase {
    DECLARAR dbService: DatabaseService

    CONSTRUTOR() {
        dbService = DatabaseService.obterInstancia()
    }

    FUNÇÃO assincrona executar(clienteId: Texto, customizacoes: Texto, enderecoDestino: Texto, totalReal: Real): Texto {
        SE customizacoes.estaVazio() OU enderecoDestino.estaVazio() OU totalReal <= 0 ENTRÃO
            LANÇAR ERRO("Dados de parametrização da encomenda ou destino inválidos.")
        FIM_SE

        NovoPedidoId = GerarUUIDV4()
        DataRegistro = ObterDataHoraAtualFormatoISO8601()

        dbService.conexaoBanco.executar(
            "INSERT INTO pedidos (id, cliente_id, detalhes, status, endereco, codigo_rastreio, valor, data_criacao) VALUES (?, ?, ?, 'AGUARDANDO_PAGAMENTO', ?, NULO, ?, ?)",
            [NovoPedidoId, clienteId, customizacoes, enderecoDestino, totalReal, DataRegistro]
        )

        RETORNAR NovoPedidoId
    }
}

```