Digital Social Innovation
=========================

Released under the MIT-LICENSE.

Setup
-----

The app is pretty much a standard Rails app, except that it uses
[Tripod](https://github.com/Swirrl/tripod) and MongoDB instead of
ActiveRecord.

All public data is stored in a Fuseki triple store, and accessed via
the ORM-like Tripod API.

All private data is stored in MongoDB.

This repository no longer contains any configuration values, so for
example to get it running you will need to copy the
`development_example.rb` file to `development.rb` and adjust the
settings for your configuration.

Like wise when deploying to production you will need to ensure some
configuration files are copied up to the server.  The capistrano setup
task will do this, but you will need to ensure that at setup time the
files are available locally.  Some example files are provided for
these production services, these are:

1. `config/s3.example.yml` which is used for image uploads.
2. `config/development_example.rb` standard rails development environment.
3. `config/production_example.rb` standard rails production environment.
4. `config/test_example.rb` standard rails test environment.
5. `config/mongoid.yml.example` example mongoid config.
6. `config/raven_production_example.rb` config initializer for mandril SMTP.
7. `config/secret_token_production_example.rb` config initializer to secure cookies with a salt.

Production
----------

To deploy to production you will need to generate a random
secret_token.

    $ irb
    1.9.3-p448 :001 > require 'securerandom'
    => true
    1.9.3-p448 :002 > SecureRandom.hex(64)
    => "0677f2adfd6d181fd5d6abf4d047f526f57db7355705ab97624b08024622c94cf72d8e3a9469667df69feb916af4bab4dcefcecd7e0d103025ad92b007676acc"

Then copy the random string into the secret_token, and copy this file
to config/initializers/secret_token_production.rb .

The capistrano setup task willl then copy this to the server in the
shared/ directory within the app.


Setting up Fuseki
-----------------

Here is an example fuseki configuration:

    @prefix tdb:     <http://jena.hpl.hp.com/2008/tdb#> .
    @prefix rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
    @prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .
    @prefix ja:      <http://jena.hpl.hp.com/2005/11/Assembler#> .
    @prefix fuseki:  <http://jena.apache.org/fuseki#> .

    [] rdf:type fuseki:Server ;
       # Services available.  Only explicitly listed services are configured.
       #  If there is a service description not linked from this list, it is ignored.
       fuseki:services (
         <#digitalsocial_dev>
         <#digitalsocial_reporting>
         <#digitalsocial_test>
       ) .

    # add more services here ^^

    [] ja:loadClass "com.hp.hpl.jena.tdb.TDB" .
    tdb:DatasetTDB  rdfs:subClassOf  ja:RDFDataset .
    tdb:GraphTDB    rdfs:subClassOf  ja:Model .

    <#junk_data> rdf:type      tdb:DatasetTDB ;
         tdb:location "/tmp/digitalsocial_dev_data" ;  # change to suit your local installation
         # Query timeout on this dataset (1s, 1000 milliseconds)
         ja:context [ ja:cxtName "arq:queryTimeout" ;  ja:cxtValue "10000,10000" ] ;
         tdb:unionDefaultGraph true ;
         .

    <#digitalsocial_dev>  rdf:type fuseki:Service ;
        fuseki:name              "digitalsocial_dev" ;       # http://host:port/myname
        fuseki:serviceQuery      "sparql" ;    # SPARQL query service  http://host:port/odc/sparql?query=...
        fuseki:serviceUpdate     "update" ;   # SPARQL update servicehttp://host:port/odc/update?query=
        fuseki:serviceReadWriteGraphStore "data" ;     # SPARQL Graph store protocol (read and write)
        fuseki:dataset           <#digitalsocial_dev_data> ;
        .

    <#digitalsocial_dev_data> rdf:type      tdb:DatasetTDB ;
         tdb:location "/tmp/digitalsocial_dev_data" ;  # change to suit your local installation
         # Query timeout on this dataset (1s, 1000 milliseconds)
         ja:context [ ja:cxtName "arq:queryTimeout" ;  ja:cxtValue "10000,10000" ] ;
         tdb:unionDefaultGraph true ;
         .

    <#digitalsocial_test_data> rdf:type      tdb:DatasetTDB ;
         tdb:location "/tmp/digitalsocial_test_data" ;  # change to suit your local installation
         # Query timeout on this dataset (1s, 1000 milliseconds)
         ja:context [ ja:cxtName "arq:queryTimeout" ;  ja:cxtValue "10000,10000" ] ;
         tdb:unionDefaultGraph true ;
         .