require 'jruby/core_ext'
require 'jar-dependencies'
require_jar 'org.springframework.boot', 'spring-boot-starter-web', '3.5.5'

java_import org.springframework.boot.SpringApplication
java_import org.springframework.web.bind.annotation.GetMapping
java_import org.springframework.web.bind.annotation.RequestParam

module SpringBoot
  java_import org.springframework.boot.autoconfigure.SpringBootApplication

  module StartMethods
    def start
      app_class = Application.become_java!
      SpringApplication.run(app_class, ARGV.to_java(:string))
    end
  end

  def self.included(mod)
    mod.extend StartMethods
    mod.add_class_annotations(SpringBootApplication => nil)
  end
end

module RestController
  java_import org.springframework.web.bind.annotation.RestController

  module BindMethods
    def get(sig, path = nil, **params)
      signature = JRuby::JavaSignature.parse sig
      name = signature.name
      path ||= "/#{name}"
      params = params.to_h { |key, default|
        [RequestParam, { "value" => key.to_s, "defaultValue" => default.to_s }]
      }

      add_method_signature(name, signature.types)
      add_method_annotation name, GetMapping => {"value" => [path].to_java(:string)}
      add_parameter_annotation name, [params]
    end
  end

  def self.included(mod)
    mod.extend BindMethods
    mod.add_class_annotations(RestController => nil)
  end
end

class HelloApp
  include SpringBoot, RestController

  get("java.lang.String hello(java.lang.String)", name: "World")
  def hello(name)
    "Hello from JRuby, #{name}!"
  end

  start
end