pipeline {
  environment {
    registry = "hazelcast/hazelcast-jet-management-center"
    dockerImage = ''
  }
  agent { label 'lab' }
  stages {
	stage('Building image') {
      steps{
        script {
          dockerImage = docker.build(registry + ":latest-snapshot", "--force-rm --no-cache --build-arg MC_VERSION=$JET_VERSION ." )
        }
      }
    }
	stage('‘Deploy image') {
      steps{
        script {
	        docker.withRegistry('', 'devopshazelcast-dockerhub') {
		        dockerImage.push()
        	} 
        }
      }
    }
  }
}  
