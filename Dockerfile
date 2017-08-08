FROM kahwee/node-ruby-dpl:latest

RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb
RUN dpkg -i dumb-init_*.deb

RUN apt-get update -qqy \
  && apt-get -qqy install \
    dumb-init gnupg wget ca-certificates apt-transport-https \
    ttf-wqy-zenhei \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install google-chrome-unstable \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*


RUN useradd headless --shell /bin/bash --create-home \
  && usermod -a -G sudo headless \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'headless:nopassword' | chpasswd

RUN mkdir /data

ENTRYPOINT ["/usr/bin/dumb-init", "--", \
  "/usr/bin/google-chrome-unstable", \
  "--disable-gpu", \
  "--headless", \
  "--remote-debugging-address=0.0.0.0", \
  "--remote-debugging-port=9222", \
  "--user-data-dir=/data"]