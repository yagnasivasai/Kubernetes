node{
    stage('Git Hub Checkout')
    {
        git credentialsId: 'GitHubCredentials', url: 'https://github.com/account/app'
    }
    stage('Build Docker Image')
    {
        bat 'docker build -t imagename/demo:v2 .'
    }
    stage('Push Docker Image Into Docker Hub')
    {
        withCredentials([string(credentialsId: 'Docker_Password', variable: 'Docker_Password')]) 
        {
            bat "docker login -u imagename -p ${Docker_Password}"
        }
        bat 'docker push imagename/demo:v2'
    }
    **stage ('Deployment Into Azure')
    {
        bat 'kubectl apply -f deployment-service.yaml'
    }**

}
