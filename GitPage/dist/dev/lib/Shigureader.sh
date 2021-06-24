pre_install(){
    ## 提升权限
    sudo -i
    ## nodejs 的安装脚本 
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
    ## yarn 的安装脚本
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | \
    sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | \
    sudo tee /etc/apt/sources.list.d/yarn.list
    ## 通过 apt 更新并按转所需软件包
    apt update && apt -y full-upgrade
    apt install -y nodejs yarn npm p7zip imagemagick git mocha unar wget nginx gcc g++ make

    mkdir -p /yukicpl/opt
    git clone https://github.com/hjyssg/ShiguReader
    mv ./ShiguReader ./shigureader
}

npm_install(){
    sudo -i
    yarn install

    
}