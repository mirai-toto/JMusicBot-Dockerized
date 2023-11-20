# Dockerized JMusicBot

This project offers a Dockerized version of JMusicBot, a Discord music bot built in Java. It utilizes a multi-stage Docker build process, ensuring an efficient and lightweight Docker image.

## Features

- **Multi-Stage Build**: Reduces the final image size by separating the build and runtime environments.
- **Environment Variable Substitution**: Dynamically substitutes environment variables in the configuration file, useful for hiding sensitive information like tokens.
- **Version Flexibility**: Automatically retrieves the latest version of JMusicBot.

## Prerequisites

- Docker
- Java (required if not using Docker)

## Getting Started

### Running the Script

1. **Clone the Repository** (if applicable):

   ```bash
   git clone https://github.com/mirai-toto/JMusicBot-Dockerized
   cd JMusicBot-Dockerized
   chmod +x run_jmusicbot.sh
   ./run_jmusicbot.sh
   ```

### Configuration

- The project includes an `.env_template` file. Copy it as `.env` and edit as needed.
- The `.env` file should contain the environment variables for substitution in `config.txt`.

## Contributing

Contributions are welcome! Feel free to create issues or submit pull requests.

## License

Apache-2.0 license

## Acknowledgments

This Dockerized version of JMusicBot is built upon the exceptional work of jagrosh, the original creator of JMusicBot. His dedicated development of the JMusicBot project inspired me to create this Docker adaptation. I am truly thankful for his significant contributions to the community and for developing such a user-friendly and efficient Discord music bot.

- JMusicBot: [JMusicBot GitHub](https://github.com/jagrosh/MusicBot)
