import "package:http/http.dart" as http;
import 'package:html/parser.dart' show parse;
import 'package:dartpedia/dartpedia.dart' as wiki;

Future<String> loadTextFromHtml(String url) async {
  //var htmlText = await _loadHttp(url);
  return _getWikiText(url);

}

Future<String> _loadHttp(String url) async {
  var response = await http.get(url);
  return response.body;
}

String _getTextFromHtml(String htmlText) {
  var document = parse(htmlText);
  return parse(document.body.text).documentElement.text;
}

Future<String> _getWikiText(String topic) async {
  wiki.WikipediaPage page = await wiki.page(topic);
  var rawContent = page.content;
  var processed = rawContent.replaceAll(RegExp(r";\d+\s?;"), "");
  processed = processed.replaceAll(RegExp(r"\[.*?\]"), "");
  processed = processed.replaceAll(RegExp(r"\(.*?\)"), "");
  processed = processed.replaceAllMapped(RegExp(r"([a-z])([A-Z])"), (Match m) => "${m[1]}. ${m[2]}");

  return processed;
}

