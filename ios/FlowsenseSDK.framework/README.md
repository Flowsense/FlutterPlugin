# SDK Flowsense iOS

## Gerando Builds de Produção

1. Atualize o número da versão do SDK (ex.: 3.2.8) no projeto e no arquivo .h chamado SDKVersion
2. Faça a build em Schema de Release com o *target* **Generic iOS Device**
3. Copie o arquivo with_push/FlowsenseSDK.framework para o projeto do git https://github.com/Flowsense/SDKiOS.git no diretório *SDKs with Push Enabled*
4. Faça *commit* da modificação e atualize a tag de acordo com a versão do SDK:
   > $ git add . && git commit -m "mensagem de commit" && git push && git tag "versão do SDK sem aspas (ex.: 3.2.8)" && git push --tags
5. Atualize o arquivo *FlowsenseSDK.podspec* com a versão atualizada do SDK (ex.: 3.2.8)
6. Atualize o repositório do CocoaPods:
   > $ pod repo push FlowsenseSDKiOSPods FlowsenseSDK.podspec --allow-warnings
