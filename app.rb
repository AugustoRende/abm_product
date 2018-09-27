require "syro"
require "mote"
require "mongo"

  Mongo::Logger.logger.level = ::Logger::FATAL

  class Web < Syro::Deck
    include Mote::Helpers

    def view(template)
      sprintf("views/%s.mote", template)
    end

    def partial(template, params = {})
      mote(view(template), params)
    end

    def render(template, params = {})
      res.html partial("layout",
        title: params[:title],
        content: partial(template, params))
    end
  end

  App = Syro.new(Web) do
    # Cloud DB
    db = Mongo::Client.new('mongodb+srv://test01:test01@cluster0-wgozz.mongodb.net/prueba')
    # db = Mongo::Client.new([ 'localhost:27017' ], :database => 'prueba')
    
    on "product" do
      get do
        render("product/index", title: "Prductos", products: db[:products].find)
      end

      on "create" do
        get do
          render("product/form", title: "Agregar Prducto")
        end

        post do
          product = {'code' => req.POST["code"], 'description' => req.POST["description"], 'price' => req.POST["price"]}
          db[:products].insert_one(product)

          res.redirect("/product")
        end
      end
      
      on "edit" do 
        on :_id do
          get do
            id = res.html inbox[:_id]
            # Problemas para obtener el elemento a editar
            product = db[:products].find({_id: id}).first
            res.html product.inspect
            # render("product/form", title: "Editar Producto", product: product)
          end

          post do
            #Actualizar Producto
            res.redirect("/product")
          end
        end
      end  
    end

    get do
      render("index", title: "Inicio", content: "Hola Mundo")
    end
  end

