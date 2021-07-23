module uim.entitysource.tests;

@safe:
import uim.entitysource;

bool test_removeOne_id_versionNumber(DEDBentitysource dataSource) {
  auto entity = OOPEntity;
  dataSource.insertOne("entities", entity);
  return dataSource.removeOne("entities", entity.id, entity.versionNumber);    
}

bool test_removeOne_collection_select(DEDBentitysource dataSource) {
  auto entity = OOPEntity;
  dataSource.insertOne("entities", entity.toJson);
  auto select = ["id": entity.id.toString, "versionNumber": to!string(entity.versionNumber)];
  return dataSource.removeOne("entities", select); 
}

bool test_removeOne_collection_select_allVersions(DEDBentitysource dataSource) {
  auto entity = OOPEntity;
  dataSource.insertOne("entities", entity.toJson);
  auto select = ["id": entity.id.toString, "versionNumber": to!string(entity.versionNumber)];
  return dataSource.removeOne("entities", select, true);
}   

bool test_removeOne_collection_jsonselect(DEDBentitysource dataSource) {
  auto entity = OOPEntity;
  dataSource.insertOne("entities", entity.toJson);
  return dataSource.removeOne("entities", entity.id, entity.versionNumber);    
}

bool test_removeOne_collection_jsonselect_allVersions(DEDBentitysource dataSource) {
  auto entity = OOPEntity;
  auto json = dataSource.insertOne("entities", entity.toJson);
  return dataSource.removeOne("entities", json, true);
}   
