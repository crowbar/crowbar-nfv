Tacker Cookbook
=================
This cookbook includes the recipes to install the tacker fork which allows to communicate with ODL directly without neutron-sfc. This fork is the one used in the OPNFV Danube release.

Requirements
------------
### Cookbooks
The following cookbooks are dependencies:

* mysql
* postgresql
* opendaylight

Limitations
-----------
There are several limitations coming from the tacker fork. Those limitations will be removed as soon as we move to the upstream tacker will should happen by the release of OPNFV Euphrates release.

1 - Only MySQL is compatible as database. PostgreSQL is not. That is why we have a recipe with hardcoded data about MySQL instead of a generic database recipe which uses the data bag db_settings to fetch specific database parameters (that is included in the db_postgre.rb recipe). As soon as the barclamp points to the latest tacker, we will just need to remove the variable db = "mysql" and point to the db_postgre.rb recipe.

2 - Tacker does only support one backend which is opendaylight. That is why the template tacker.conf.erb has the infra_driver parameter hardcoded as opendaylight. This should be changed as soon as we move to the upstream tacker.

TO DO
----------
Apart from the things which must be done which are already listed in the Limitations section, there are some things which should be improved.

1 - There is a hard dependency with ODL listed in the Requirements, however, if the barclamp is installed without ODL it will fail. There should be some logic which warns the user or prevents the user from installing the barclamp if ODL is not there. The dependency is in the tacker.conf.erb port parameter which is taken from the opendaylight data_bag. Adding a hardcoded port will make things work (remove it also from default.rb).

2 - Test it for other non-ODL use cases
