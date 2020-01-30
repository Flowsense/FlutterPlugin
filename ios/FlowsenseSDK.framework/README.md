# SDK Flowsense iOS
## Gerando Builds de Produção
* Certificar-se da inexistência de logs desnecessário e/ou indesejáveis para o cliente;
* Certificar-se da inexistência de mensagens e métodos de debug desnecessário e/ou indesejáveis para o cliente;
* Certificar-se da existência do Target Aggregate do Build Phases → Run Script;
* Mudar a versão do SDK em General → Identity → Version;
* Commitar quaisquer alterações para o git;
* Gerar o SDK com e sem push e para React selecionando **Aggregate > Generic iOS Device** e dando um build no projeto (CMD + B). O script do item 3 se encarregará de gerar as versões automaticamente em /Desktop/with(without)_push/FlowsenseSDK-Release-iphoneuniversal;
* Atualizar o Carthage:
    * Copiar as versões geradas dos frameworks para as pastas correspondentes do https://github.com/Flowsense/SDKiOS;
    * Executar:
        * $ git add . && git commit -m <Mensagem do Commit> && git push && git tag <no. da versão (ex 1.0.0)> && git push --tags
* Note: a mensagem de commit acima é pública, bem como o repositório.
