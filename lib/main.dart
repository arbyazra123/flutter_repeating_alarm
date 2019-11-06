import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:prospek/editdata.dart';
import 'package:prospek/utils/Constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:async';
import 'DetailData.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'AddData.dart';

void main() {
  runApp(new MaterialApp(
    home: MyApp(isRefresh: false,),
    debugShowCheckedModeBanner: false,

  ));
}

class MyApp extends StatefulWidget {
  final bool isRefresh;

  const MyApp({Key key, this.isRefresh}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController searchTec = new TextEditingController();
  //InitializationAlarm
  FlutterLocalNotificationsPlugin localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  initializeNotifications() async {
    var initializeAndroid = AndroidInitializationSettings('ic_launcher');
    var initializeIOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(initializeAndroid, initializeIOS);
    await localNotificationsPlugin.initialize(initSettings,onSelectNotification: onSelectNotifications);
  }
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  Future onSelectNotifications(String payload){
    if(payload!=null){
      print("Notification payload "+payload);
    }
    Navigator.push(context,MaterialPageRoute(
      builder: (context)=>Detail(id: payload)
    ));
  }

  bool loading =false;
  List dataJson=[];

  void getData() async {
    setState(() {
      loading=true;
    });
    final response =
        await http.get(Uri.parse(Constants.GET_PROSPECT));
    var data = jsonDecode(response.body);
    if(response.statusCode==200){
      setState(() {

        for(var i=0;i<data.length;i++){
          dataJson.add(data[i]);
      }
      });

    } else {
      Fluttertoast.showToast(
          msg: "Swipe down to refresh",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    setState(() {
      loading=false;
    });

  }

  void _onRefresh() async{
    // monitor network fetch;

    await Future.delayed(Duration(milliseconds: 1000));
    dataJson.clear();
    getData();
    // if failed,use refreshFailed()
    if(mounted)
      setState(() {
      });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    // monitor network fetch

    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    dataJson.clear();
    getData();
    if(mounted)
      setState(() {
      });

    _refreshController.loadComplete();
  }

  String filter;

  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.isRefresh){
      _onRefresh();

    } else {
      getData();
    }
    searchTec.addListener((){
      setState(() {
        filter = searchTec.text;
      });
    });
    initializeNotifications();
  }

  @override
  void dispose() {
    searchTec.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: new AppBar(
          title: new Center(child: new Text("Funnel Prospect Controling"),),
          backgroundColor: Colors.blue,
        ),

        floatingActionButton: new FloatingActionButton(
          child: new Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pushReplacement(new MaterialPageRoute(
                builder: (BuildContext context) => new AddData(),
              )),
        ),



        body:
        SmartRefresher(
          enablePullDown: true,
          header: WaterDropMaterialHeader(),
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          controller: _refreshController,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 15),
                child: TextFormField(
                  controller: searchTec,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: (){}
                      ),
                      hintText: "Search..."),
                ),
              ),
              loading?Center(child: CircularProgressIndicator(),): dataJson.length!=0?  ListView.builder(
                shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: dataJson.length,
                  itemBuilder: (context, i) {
                    return filter ==null||filter==""?new Container(
                      child: new GestureDetector(
                        onTap: () => Navigator.of(context).pushReplacement(new MaterialPageRoute(
                            builder: (BuildContext context) => new Detail(
                              id: dataJson[i]['id'],
                            ))),
                        child: new Card(
                          color: Colors.white,
                          child: new ListTile(
                            title: new Text(dataJson[i]['nama']),
                            leading: new Icon(Icons.people),
                            subtitle: new Text("Tanggal : ${dataJson[i]['created_at']} \nStatus: ${dataJson[i]['prospek']} \n " ),
                            trailing: InkWell(
                                onTap: ()=>launch("tel://"+dataJson[i]['nohp']),
                                child: new Icon(Icons.call)),
                            isThreeLine: true,

                          ),
                        ),
                      ),
                    ) :dataJson[i]['nama'].toLowerCase().contains(filter.toLowerCase())? new Container(
                      child: new GestureDetector(
                        onTap: () => Navigator.of(context).pushReplacement(new MaterialPageRoute(
                            builder: (BuildContext context) => new Detail(
                              id: dataJson[i]['id'],
                            ))),
                        child: new Card(
                          color: Colors.white,
                          child: new ListTile(
                            title: new Text(dataJson[i]['nama']),
                            leading: new Icon(Icons.people),
                            subtitle: new Text("Tanggal : ${dataJson[i]['created_at']} \nStatus: ${dataJson[i]['prospek']} \n " ),
                            trailing: InkWell(
                                onTap: ()=>launch("tel://"+dataJson[i]['nohp']),
                                child: new Icon(Icons.call)),
                            isThreeLine: true,

                          ),
                        ),
                      ),
                    ):new Container();
                  }
              ): Center(child: Text("Data Kosong"),),
            ],
          ),
        ),


        )
    );
  }
}


