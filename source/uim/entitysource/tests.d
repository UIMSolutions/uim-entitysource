module uim.entitysource.tests;

@safe:
import uim.entitysource;

bool test_findOne_id(DESCEntitySource dataSource) {
  auto id = UUID("0a9f35a0-be1f-4f3f-9d03-97bfba36774d");
  auto json = dataSource.findOne("entities", id);
  return json != Json(null) && json["id"].get!string == id.toString;
}
bool test_findOne_id_allVersions(DESCEntitySource dataSource) {
  auto id = UUID("0a9f35a0-be1f-4f3f-9d03-97bfba36774d");
  auto json = dataSource.findOne("entities", id, true);
  return json != Json(null) && json["id"].get!string == id.toString;
}
bool test_findOne_id_versionNumber(DESCEntitySource dataSource) {
  auto id = UUID("0a9f35a0-be1f-4f3f-9d03-97bfba36774d");
  auto json = dataSource.findOne("entities", id, 1);
  return json != Json(null) && json["id"].get!string == id.toString;
}
bool test_findOne_select(DESCEntitySource dataSource) {
  auto id = UUID("0a9f35a0-be1f-4f3f-9d03-97bfba36774d");
  auto select = ["id": id.toString];
  auto json = dataSource.findOne("entities", select);
  return json != Json(null) && json["id"].get!string == id.toString;
}
bool test_findOne_select_allVersions(DESCEntitySource dataSource) {
  auto id = UUID("0a9f35a0-be1f-4f3f-9d03-97bfba36774d");
  auto select = ["id": id.toString];
  auto json = dataSource.findOne("entities", select, true);
  return json != Json(null) && json["id"].get!string == id.toString;
}
bool test_findOne_select_versionNumber(DESCEntitySource dataSource) {
  auto id = UUID("0a9f35a0-be1f-4f3f-9d03-97bfba36774d");
  auto select = ["id": id.toString];
  auto json = dataSource.findOne("entities", select, 1);
  return json != Json(null) && json["id"].get!string == id.toString;
}
bool test_removeOne_id_versionNumber(DESCEntitySource dataSource) {
  auto entity = OOPEntity;
  dataSource.insertOne("entities", entity);
  return dataSource.removeOne("entities", entity.id, entity.versionNumber);    
}
bool test_removeOne_collection_select(DESCEntitySource dataSource) {
  auto entity = OOPEntity;
  dataSource.insertOne("entities", entity.toJson);
  auto select = ["id": entity.id.toString, "versionNumber": to!string(entity.versionNumber)];
  return dataSource.removeOne("entities", select); 
}
bool test_removeOne_collection_select_allVersions(DESCEntitySource dataSource) {
  auto entity = OOPEntity;
  dataSource.insertOne("entities", entity.toJson);
  auto select = ["id": entity.id.toString, "versionNumber": to!string(entity.versionNumber)];
  return dataSource.removeOne("entities", select, true);
}   

bool test_removeOne_collection_jsonselect(DESCEntitySource dataSource) {
  auto entity = OOPEntity;
  dataSource.insertOne("entities", entity.toJson);
  return dataSource.removeOne("entities", entity.id, entity.versionNumber);    
}

bool test_removeOne_collection_jsonselect_allVersions(DESCEntitySource dataSource) {
  auto entity = OOPEntity;
  auto json = dataSource.insertOne("entities", entity.toJson);
  return dataSource.removeOne("entities", json, true);
}   
