import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:http/http.dart' as http;

/*
Future<(String, List, List)> uGetFeed(String address) async {
  List<String> titles = [];
  List<String> links = [];

  var feedUrl = address;
  String title = "?";

  var text = await http.read(Uri.parse(feedUrl));
  var channel = RssFeed.parse(text);

  title = channel.title!;
  if (channel.items != null) {
    for (var item in channel.items!) {
      titles.add(item.title!);
      links.add(item.link!);
    }
  }
  
  return (title, titles, links);
}
*/

Future<(String, List, List)> uGetFeed(String address) async {
  List<String> titles = [];
  List<String> links = [];
  List<RssItem> items = [];

  String title = "?";

  try {
    final response = await http.get(Uri.parse(address));
    if (response.statusCode == 200) {
      final feed = RssFeed.parse(response.body);

      items = feed.items ?? [];
      title = feed.title!;
      if (feed.items != null) {
        for (var item in items) {
          titles.add(item.title!);
          links.add(item.link!);
        }
      }
    }
  } catch (e) {
    print('Error fetching RSS feed: $e');
  }

  print(title);
  return (title, titles, links);
}
