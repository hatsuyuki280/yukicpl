pre_install(){
    sudo -i
    apt update && apt -y full-upgrade
    apt install -y nodejs npm p7zip imagemagick git mocha unar wget nginx

    mkdir -p /yukicpl/opt
    git clone https://github.com/hjyssg/ShiguReader
    mv ./ShiguReader ./shigureader
}

npm_install(){
    sudo -i
    npm install --prefix .

    
}