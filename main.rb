require 'jruby/core_ext'
require 'jar-dependencies'
require_jar 'org.springframework.boot', 'spring-boot-starter-web', '3.5.5'

java_import org.springframework.boot.SpringApplication
java_import org.springframework.boot.autoconfigure.SpringBootApplication
java_import org.springframework.web.bind.annotation.RestController
java_import org.springframework.web.bind.annotation.GetMapping
java_import org.springframework.web.bind.annotation.RequestParam

class Application
  add_class_annotations(SpringBootApplication => nil, RestController => nil)

  add_method_annotation "hello", GetMapping => {"value" => ["/hello"].to_java(:string)}
  add_parameter_annotation "hello", [
    RequestParam => {"value" => "name", "defaultValue" => "Spring Boot"}
  ]
  java_signature "java.lang.String hello(java.lang.String)"
  def hello(name)
    "Hello from JRuby, #{name}"
  end
end

app_class = Application.become_java!
context = SpringApplication.run(app_class, ARGV.to_java(:string))

