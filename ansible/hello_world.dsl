// hello_world_job.dsl
pipelineJob('HelloWorldPipeline') {
  definition {
    cps {
      script("""
        pipeline {
            agent any
            stages {
                stage('echo Hello!') {
                    steps {
                        script {
                            sh "echo 'Hello World!'"
                        }
                    }
                }
            }   
        }
      """.stripIndent())
      sandbox(true)
    }
  }
}
