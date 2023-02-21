import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:hive/hive.dart';
// import 'package:path_provider/path_provider.dart';
void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('mydb');
  runApp(HomePage());
}
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Map<String,dynamic>>database=[];
  final box=Hive.box('mydb');
  @override
  void initState() {
    super.initState();
    _refreshItem();
  }
  void _refreshItem(){
    final item=box.keys.map((key) {
      final value=box.get(key);
      return {'key':key,'name':value['name'],'contact':value['contact']};
    }).toList();
    setState(() {
      database=item.reversed.toList();
    });
}


  Future<void>createItem(Map<String, dynamic> newItem) async {
    await box.add(newItem);
    _refreshItem();
  }

  Future<void>updateItem(int itemkey, Map<String, dynamic> editedItem) async{
    await box.put(itemkey, editedItem);
    _refreshItem();
  }

  Future <void> deleteItem(current_item) async {
    await box.delete(current_item);
    _refreshItem();
  }

  final name_controller=TextEditingController();
  final contact_controller=TextEditingController();
  _showform(BuildContext context,int? Itemkey) async{
    if(Itemkey != null){
      final existingData=database.firstWhere((element) => element['key']==Itemkey);
      name_controller.text=existingData['name'];
      contact_controller.text=existingData['contact'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 3,
        isScrollControlled: true,
        builder: (context){
          return Container(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              top: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: name_controller,
                  decoration: InputDecoration(
                      hintText: 'name',
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(height: 10,),
                TextField(
                  controller: contact_controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: 'contact',
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.only(left: 100),
                  child: ElevatedButton(
                    onPressed: ()async{
                      if(Itemkey==null){
                        createItem({'name':name_controller.text,'contact':contact_controller.text});
                      }
                      if(Itemkey!=null){
                        await updateItem(Itemkey,{'name':name_controller.text.trim(),'contact':contact_controller.text.trim()});
                      }
                      name_controller.clear();
                      contact_controller.clear();
                      Navigator.of(context).pop();
                    },
                    child: Text(Itemkey==null?'create':'update'),
                  ),
                )
              ],
            ),

          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hive Demo'),
      ),
      body: database.isEmpty?
      Center(
        child: CircularProgressIndicator(),
      )
          :ListView.builder(
        itemCount: database.length,
        itemBuilder: (context,index){
          final currentItem=database[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(currentItem['name']),
              subtitle: Text(currentItem['contact'].toString()),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(onPressed: (){
                      _showform(context,currentItem['key']);
                    }, icon: Icon(Icons.edit),),
                    IconButton(onPressed: (){
                      deleteItem(currentItem['key']);
                    }, icon: Icon(Icons.delete)),
                  ],
                ),
              ),
            ),
          );
        }
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showform(context,null);
        },
        child: Icon(Icons.add),
      ),
    );
  }

}

