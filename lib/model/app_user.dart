class AppUser {
  final String uid;
  final String? email;
 final String? name;
 final String? photoUrl;


  AppUser({
required this.uid,
    this.email,
    this.name, this.photoUrl,
});


// Fire store to Dart object conversion
factory AppUser.fromMap(Map<String,dynamic>data,String uid){
  return AppUser(
    uid: uid,
    email: data['email'],
    name: data['name'],
    photoUrl: data['photoUrl'],
  );
}
//Dart Object to Firestore
  Map<String,dynamic> toMap(){
    return{
    'email': email,
    'name': name,
      'photoUrl': photoUrl,
  };
}
}