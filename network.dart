import 'package:dio/dio.dart';
import 'package:newsapp/constant.dart';
import 'package:newsapp/model/comments.dart';
import 'package:newsapp/model/news.dart';
import 'package:newsapp/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<News>> getNews(String cat) async {
  List<News> newsList = [];
  var response = await Dio()
      .post(server_url + "/news_api/", data: FormData.fromMap({"cat": cat}));
  for (var u in response.data) {
    newsList.add(News(u['news_url'], u['news_title'], u['news_img_url'],
        u['news_content'], u['time'], u['source_name']));
  }
  return newsList;
}

Future<List<News>> searchNews(String query) async {
  List<News> newsList = [];
  var response = await Dio().post(
    server_url + '/news_api/search/',
    data: FormData.fromMap({"query": query}),
  );
  print(response.data);
  for (var u in response.data) {
    newsList.add(News(u['news_url'], u['news_title'], u['news_img_url'],
        u['news_content'], u['time'], u['source_name']));
  }
  return newsList;
}

Future<List<Comment>> getComment(String url, String email) async {
  List<Comment> commentList = [];
  var response = await Dio().post(
    server_url + '/news_api/comments/',
    data: FormData.fromMap({"news_url": url, "email": email}),
  );
  if (email != "") {
    for (var u in response.data) {
      commentList.add(Comment(u['comment_id'], u['user_name'],u['comment_content'], int.parse(u['like_count']), u['user_like_status']));
    }
  }
  else
  {
    for (var u in response.data) {
      commentList.add(Comment(u['comment_id'], u['user_name'],
          u['comment_content'], u['like_count'], 0));
    }
  }
  return commentList;
}

Future<void> sendUser(User account) async {
  print("object");
  var response = await Dio().post(
    server_url + "/news_api/usr/",
    data: FormData.fromMap({
      "usr_name": account.userName,
      "usr_email": account.userEmail,
      "usr_pass": account.userPassword,
    }),
  );

  print(response);
}

Future<String> getUser(String email, String password) async {
  var response = await Dio().post(
    server_url + "/news_api/login/",
    data: FormData.fromMap({
      "usr_email": email,
      "usr_pass": password,
    }),
  );
  return response.data["status"];
}

Future<void> sendComment(String comment, String url) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var response = await Dio().post(
    server_url + "/news_api/cmnt_add/",
    data: FormData.fromMap({
      "comnt": comment,
      "email": prefs.getString("email"),
      "news_url": url,
    }),
  );

  print(response);
}

Future<void> setLike(String news_url, bool cmd) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String email = pref.getString("email") ?? "";
  String ops = "";
  if (cmd) {
    ops = "like";
  } else {
    ops = "dislike";
  }
  var res = await Dio().post(server_url + "/news_api/like/",
      data:
          FormData.fromMap({"news_url": news_url, "email": email, "cmd": ops}));

  print(res);
}

Future<void> setCommentLike(int id, int cmd) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String email = pref.getString("email") ?? "";
  String ops = "";
  if (cmd == 1) {
    ops = "like";
  } else {
    ops = "dislike";
  }
  var res = await Dio().post(server_url + "/news_api/comment_like/",
      data: FormData.fromMap({"comment_id": id, "email": email, "cmd": ops}));
}
