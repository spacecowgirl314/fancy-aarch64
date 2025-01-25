# Start with the Fedora IoT base image
FROM registry.fedoraproject.org/fedora-iot:latest

# Set metadata for the image
LABEL maintainer="your-email@example.com" \
      description="A Docker image based on Fedora IoT for IoT projects."

# Update the package repository and install basic tools (optional)
# RUN dnf -y update && \
#     dnf -y install \
#     bash \
#     nano \
#     curl \
#     fish \
#     git && \
#     dnf clean all

RUN rpm-ostree install \
    bash \
    nano \
    curl \
    fish \
    git

# rpm-ostree \

# Set fish as the default shell for the container
RUN echo "/usr/bin/fish" >> /etc/shells && \
    chsh -s /usr/bin/fish

SHELL ["/usr/bin/fish", "-c"]

# Install Linuxbrew
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

# Set the working directory inside the container
WORKDIR /app

# Copy your application or configuration files into the container (optional)
# Uncomment and modify the line below to suit your project
# COPY ./my-app /app

# Set environment variables (optional)
ENV MY_ENV_VAR=example_value

# Define the default command to run in the container
CMD ["/usr/bin/fish"]
