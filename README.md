
# 🎬 Fila de Filmes com Flutter

Um aplicativo para organizar e acompanhar os filmes que você quer assistir, feito com Flutter e Firebase, para fins de estudo e portfólio.

---

## 🚀 Tecnologias

Este projeto foi desenvolvido com as seguintes tecnologias:

- [Flutter](https://flutter.dev/) e [Dart](https://dart.dev/)
- [Firebase](https://firebase.google.com/) (Cloud Firestore e Authentication)
- [The Movie Database (TMDb) API](https://www.themoviedb.org/documentation/api) para dados de filmes
- Arquitetura de Features

---

## 📂 Estrutura do Projeto

A estrutura do projeto foi organizada para ser escalável, separando as responsabilidades em features.

```
/futter_movies_queue
│
├── lib/
│   ├── core/                   # Serviços (Firestore), modelos base, etc.
│   ├── features/               # Módulos da aplicação (filmes, autenticação)
│   │   └── movies/
│   │       ├── models/         # Modelos de dados (Movie)
│   │       ├── screens/        # Telas da feature (Home, Detalhes, etc.)
│   │       └── widgets/        # Widgets reutilizáveis (MovieCard)
│   │
│   ├── main.dart               # Ponto de entrada da aplicação
│   └── ...
│
├── pubspec.yaml                # Dependências e metadados do projeto
└── README.md                   # Este arquivo
```

---

## 📥 Instalação e Configuração

```bash
# Clone este repositório
git clone [https://github.com/ferreiraryan/futter_movies_queue](https://github.com/ferreiraryan/futter_movies_queue)

# Acesse o diretório
cd futter_movies_queue

# Instale as dependências
flutter pub get
```

### Configuração do Firebase

Para que o projeto funcione, você precisa configurar seu próprio projeto no Firebase:

1.  Crie um projeto no [console do Firebase](https://console.firebase.google.com/).
2.  Adicione um aplicativo Android e/ou iOS.
3.  Siga as instruções para baixar o arquivo de configuração (`google-services.json` para Android ou `GoogleService-Info.plist` para iOS) e coloque-o na pasta correta do seu projeto Flutter.
4.  Ative o **Cloud Firestore** e o **Authentication** (com o provedor "Anônimo") no console.

```bash
# Após configurar o Firebase, execute o projeto
flutter run
```

---

## 🛠️ Como usar

O aplicativo permite que você gerencie sua fila de filmes de forma simples e intuitiva:

- **Pesquisar**: Encontre qualquer filme usando a busca integrada com a API do TMDb.
- **Adicionar à Fila**: Adicione filmes que você tem interesse à sua lista de "Para Assistir".
- **Organizar**: Reordene sua lista de "Para Assistir" arrastando os filmes para definir a prioridade.
- **Marcar como Assistido**: Mova um filme para a sua lista de "Assistidos". A data da visualização é salva automaticamente.
- **Avaliar**: Dê uma nota para os filmes que você já assistiu.

---

## 🤝 Contribuindo

Sinta-se à vontade para contribuir! Basta seguir os passos abaixo:

1. Faça um **fork** do projeto.
2. Crie uma **branch** com a sua feature: `git checkout -b minha-feature`
3. Faça **commit** das suas alterações: `git commit -m 'Adiciona nova feature'`
4. Envie para o GitHub: `git push origin minha-feature`
5. Abra um **Pull Request**

---

## 📬 Contato

- **Ryan Ferreira** - [ryanferreira4883@gmail.com](mailto:ryanferreira4883@gmail.com)
- **GitHub** - [https://github.com/ferreiraryan](https://github.com/ferreiraryan)
- **LinkedIn** - [https://www.linkedin.com/in/ferryan/](https://www.linkedin.com/in/ferryan/)

---

