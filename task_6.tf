provider "aws" {
  version = "~> 2.0"
  region  = "ap-south-1"
  profile = "default"
}

provider "kubernetes" {
  config_context_cluster  = "minikube"
}

resource "kubernetes_persistent_volume_claim" "pvc" {
  metadata {
    name = "pvc"
    labels = {
      app = "wordpress"
    }
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}



resource "kubernetes_deployment" "wp-deploy" {
  metadata {
    name = "wp"
    labels = {
      app = "wordpress"
     
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "wordpress"
       
      }
    }
    
    template {
      metadata {
        labels = {
          app = "wordpress"
          
        }
      }
      spec {
        volume {
          name = "wp-pvc"
          persistent_volume_claim {
            claim_name = "pvc"
          }
        }
        container {
           image = "wordpress"
           name  = "wp-container"
           port {
             container_port = 80
           }
           volume_mount {
             name = "wp-pvc"
             mount_path = "/var/www/html"
           }
        }
      }
    }
  }

}


resource "kubernetes_service" "expose" {
  metadata {
    name = "wpservice"
    labels = {
      app = "wordpress"
    }
  }
  spec {
    selector = {
      app = "wordpress"
    }
  port {
    node_port   = 31000
    port        = 80
    target_port = 80
  }
  type = "NodePort"
 }
}

resource "aws_db_instance" "rds" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  identifier           = "wordpress-db"
  name                 = "task_6"
  username             = "root"
  password             = "redhat123"
  port                 = 3306
  skip_final_snapshot = true
  publicly_accessible = true
  apply_immediately = true
  
}
output "endpoint" {
value = aws_db_instance.rds.endpoint

}