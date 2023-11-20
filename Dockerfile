###########################################################################################################################
################################## Stage 1: Substitution stage using alpine base image ##################################
###########################################################################################################################
FROM alpine:3.18 AS subst_stage

# Install gettext package for envsubst
RUN apk add --no-cache gettext

# Set working directory
WORKDIR /subst

# Copy the .env file and config.txt to the container
COPY .env config.txt ./

# Perform the substitution
RUN export $(cat .env | xargs) && envsubst < config.txt > config_subst.txt

###########################################################################################################################
################################## Stage 2: Main application stage using OpenJDK runtime ##################################
###########################################################################################################################

FROM openjdk:8-jre-alpine

ARG JMUSICBOT_VERSION

# Set the working directory inside the container
WORKDIR /app

# Copy the JMusicBot.jar from the context
COPY JMusicBot-${JMUSICBOT_VERSION}.jar ./JMusicBot.jar

# Copy the substituted config file from the substitution stage
COPY --from=subst_stage /subst/config_subst.txt ./config.txt

# Set the command to run your Java application
CMD ["java", "-Dnogui=true", "-jar", "JMusicBot.jar"]