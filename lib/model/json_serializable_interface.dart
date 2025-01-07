abstract class JsonSerializableInterface<TThisType> {
  TThisType fromJson2(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
