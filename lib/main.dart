import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const deliveryCharge = 150;
const whatsappNumber = '8801748586898';

void main() => runApp(const UshaApp());

class Product {
  final String name, category, unit, emoji, description;
  final int price;
  const Product(this.name,this.category,this.unit,this.price,this.emoji,this.description);
}

const products=[
  Product('শুকনো কচুর লতি','শুকনো সবজি','250 গ্রাম',220,'🥬','পরিষ্কার ও স্বাস্থ্যসম্মতভাবে শুকানো।'),
  Product('শুকনো আলু','শুকনো সবজি','250 গ্রাম',180,'🥔','রান্নার জন্য প্রস্তুত শুকনো আলু।'),
  Product('সবজি খিচুড়ি মিক্স','খিচুড়ি মিক্স','500 গ্রাম',250,'🍚','সহজে রান্নার জন্য প্রস্তুত মিশ্রণ।'),
  Product('মসলা খিচুড়ি মিক্স','খিচুড়ি মিক্স','500 গ্রাম',280,'🍲','সুগন্ধি মসলাসহ খিচুড়ি মিক্স।'),
  Product('ঊষা কটন কাপড়','কাপড়','১ পিস',650,'👕','আরামদায়ক কটন কাপড়।'),
  Product('ঘরোয়া শুকনো খাবার','খাবার','500 গ্রাম',300,'🍱','ঘরোয়া স্বাদের শুকনো খাবার।'),
];

class UshaApp extends StatefulWidget { const UshaApp({super.key}); @override State<UshaApp> createState()=>_UshaAppState(); }
class _UshaAppState extends State<UshaApp>{
  final Map<Product,int> cart={}; int tab=0; String search='';
  int get subtotal=>cart.entries.fold(0,(s,e)=>s+e.key.price*e.value);
  int get total=>subtotal+(cart.isEmpty?0:deliveryCharge);
  void add(Product p)=>setState(()=>cart[p]=(cart[p]??0)+1);
  void qty(Product p,int n)=>setState((){if(n<=0)cart.remove(p);else cart[p]=n;});
  @override Widget build(BuildContext c)=>MaterialApp(
    debugShowCheckedModeBanner:false,title:'ঊষা',
    theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:Colors.orange)),
    home:Scaffold(
      appBar:AppBar(title:const Text('☀️ ঊষা',style:TextStyle(fontWeight:FontWeight.bold)),centerTitle:true,
        actions:[IconButton(onPressed:()=>setState(()=>tab=2),icon:Badge(label:Text('${cart.values.fold(0,(a,b)=>a+b)}'),child:const Icon(Icons.shopping_cart_outlined)))]),
      body:IndexedStack(index:tab,children:[
        Home(search:search,onSearch:(v)=>setState(()=>search=v),onAdd:add),
        Categories(onAdd:add),
        Cart(cart:cart,subtotal:subtotal,total:total,onQty:qty,onCheckout:()=>setState(()=>tab=3)),
        Checkout(cart:cart,subtotal:subtotal,total:total),
        const Account(),
      ]),
      bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),destinations:const[
        NavigationDestination(icon:Icon(Icons.home_outlined),label:'হোম'),
        NavigationDestination(icon:Icon(Icons.category_outlined),label:'ক্যাটাগরি'),
        NavigationDestination(icon:Icon(Icons.shopping_cart_outlined),label:'কার্ট'),
        NavigationDestination(icon:Icon(Icons.receipt_long_outlined),label:'অর্ডার'),
        NavigationDestination(icon:Icon(Icons.person_outline),label:'অ্যাকাউন্ট'),
      ]),
    ));
}

class Home extends StatelessWidget{
 final String search; final ValueChanged<String> onSearch; final ValueChanged<Product> onAdd;
 const Home({super.key,required this.search,required this.onSearch,required this.onAdd});
 @override Widget build(BuildContext c){
  final list=products.where((p)=>p.name.contains(search)||p.category.contains(search)).toList();
  return ListView(padding:const EdgeInsets.all(16),children:[
   Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:Colors.orange.shade100,borderRadius:BorderRadius.circular(22)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('প্রকৃতির স্বাদ, ঘরে ঘরে',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),SizedBox(height:7),
    Text('শুকনো সবজি, খিচুড়ি মিক্স, কাপড় ও খাবার'),SizedBox(height:10),Chip(label:Text('🚚 সারা বাংলাদেশে ডেলিভারি ৳১৫০'))
   ])),
   const SizedBox(height:15),
   TextField(onChanged:onSearch,decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'পণ্য খুঁজুন',border:OutlineInputBorder())),
   const SizedBox(height:15),const Text('জনপ্রিয় পণ্য',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
   ...list.map((p)=>ProductTile(p,onAdd)),
  ]);
 }
}

class Categories extends StatelessWidget{
 final ValueChanged<Product> onAdd; const Categories({super.key,required this.onAdd});
 @override Widget build(BuildContext c){
  const cats=['শুকনো সবজি','খিচুড়ি মিক্স','কাপড়','খাবার'];
  return ListView(padding:const EdgeInsets.all(12),children:cats.map((x)=>ExpansionTile(title:Text(x,style:const TextStyle(fontWeight:FontWeight.bold)),children:products.where((p)=>p.category==x).map((p)=>ProductTile(p,onAdd)).toList())).toList());
 }
}

class ProductTile extends StatelessWidget{
 final Product p; final ValueChanged<Product> add; const ProductTile(this.p,this.add,{super.key});
 @override Widget build(BuildContext c)=>Card(child:ListTile(
  leading:CircleAvatar(radius:27,child:Text(p.emoji,style:const TextStyle(fontSize:27))),
  title:Text(p.name),subtitle:Text('${p.unit}\n${p.description}'),isThreeLine:true,
  trailing:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text('৳${p.price}',style:const TextStyle(fontWeight:FontWeight.bold)),FilledButton(onPressed:()=>add(p),child:const Text('যোগ'))]),
 ));
}

class Cart extends StatelessWidget{
 final Map<Product,int> cart; final int subtotal,total; final void Function(Product,int) onQty; final VoidCallback onCheckout;
 const Cart({super.key,required this.cart,required this.subtotal,required this.total,required this.onQty,required this.onCheckout});
 @override Widget build(BuildContext c){
  if(cart.isEmpty)return const Center(child:Text('আপনার কার্ট খালি',style:TextStyle(fontSize:20)));
  return Column(children:[
   Expanded(child:ListView(children:cart.entries.map((e)=>ListTile(
    leading:Text(e.key.emoji,style:const TextStyle(fontSize:28)),title:Text(e.key.name),
    subtitle:Text('৳${e.key.price} × ${e.value} = ৳${e.key.price*e.value}'),
    trailing:Row(mainAxisSize:MainAxisSize.min,children:[IconButton(onPressed:()=>onQty(e.key,e.value-1),icon:const Icon(Icons.remove_circle_outline)),Text('${e.value}'),IconButton(onPressed:()=>onQty(e.key,e.value+1),icon:const Icon(Icons.add_circle_outline))],
   )).toList())),
   Padding(padding:const EdgeInsets.all(16),child:Column(children:[
    Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('পণ্যের মোট'),Text('৳$subtotal')]),
    const Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('ডেলিভারি'),Text('৳150')]),
    const Divider(),Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('সর্বমোট',style:TextStyle(fontWeight:FontWeight.bold,fontSize:18)),Text('৳$total',style:const TextStyle(fontWeight:FontWeight.bold,fontSize:18))]),
    const SizedBox(height:8),SizedBox(width:double.infinity,child:FilledButton(onPressed:onCheckout,child:const Text('অর্ডার করতে এগিয়ে যান')))
   ]))
  ]);
 }
}

class Checkout extends StatefulWidget{
 final Map<Product,int> cart; final int subtotal,total;
 const Checkout({super.key,required this.cart,required this.subtotal,required this.total});
 @override State<Checkout> createState()=>_CheckoutState();
}
class _CheckoutState extends State<Checkout>{
 final name=TextEditingController(),phone=TextEditingController(),address=TextEditingController(),note=TextEditingController();
 @override void dispose(){name.dispose();phone.dispose();address.dispose();note.dispose();super.dispose();}
 Future<void> send() async{
  if(widget.cart.isEmpty||name.text.trim().isEmpty||phone.text.trim().length<11||address.text.trim().isEmpty){
   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('নাম, সঠিক মোবাইল নম্বর ও সম্পূর্ণ ঠিকানা দিন।')));return;
  }
  final items=widget.cart.entries.map((e)=>'• ${e.key.name} — ${e.key.unit} × ${e.value} = ৳${e.key.price*e.value}').join('\n');
  final id='USHA${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
  final msg='''🛍️ ঊষা – নতুন অর্ডার
অর্ডার নম্বর: $id

👤 নাম: ${name.text.trim()}
📱 মোবাইল: ${phone.text.trim()}
📍 ঠিকানা: ${address.text.trim()}
${note.text.trim().isEmpty?'':'📝 নোট: ${note.text.trim()}'}

📦 পণ্য:
$items

পণ্যের মোট: ৳${widget.subtotal}
ডেলিভারি চার্জ: ৳150
💰 সর্বমোট: ৳${widget.total}
পেমেন্ট: ক্যাশ অন ডেলিভারি''';
  final uri=Uri.parse('https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(msg)}');
  if(await canLaunchUrl(uri)) await launchUrl(uri,mode:LaunchMode.externalApplication);
  else if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('WhatsApp খোলা যাচ্ছে না।')));
 }
 @override Widget build(BuildContext c)=>ListView(padding:const EdgeInsets.all(18),children:[
  const Text('অর্ডার সম্পন্ন করুন',style:TextStyle(fontSize:23,fontWeight:FontWeight.bold)),const SizedBox(height:14),
  TextField(controller:name,decoration:const InputDecoration(labelText:'আপনার নাম',border:OutlineInputBorder())),const SizedBox(height:10),
  TextField(controller:phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'মোবাইল নম্বর',border:OutlineInputBorder())),const SizedBox(height:10),
  TextField(controller:address,maxLines:3,decoration:const InputDecoration(labelText:'সম্পূর্ণ ঠিকানা',border:OutlineInputBorder())),const SizedBox(height:10),
  TextField(controller:note,maxLines:2,decoration:const InputDecoration(labelText:'বিশেষ নির্দেশনা (ঐচ্ছিক)',border:OutlineInputBorder())),const SizedBox(height:16),
  Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(children:[const Text('পেমেন্ট: ক্যাশ অন ডেলিভারি'),const SizedBox(height:6),Text('সর্বমোট: ৳${widget.total}',style:const TextStyle(fontWeight:FontWeight.bold,fontSize:18))]))),
  const SizedBox(height:10),SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:send,icon:const Icon(Icons.send),label:const Text('WhatsApp-এ অর্ডার পাঠান')))
 ]);
}

class Account extends StatelessWidget{
 const Account({super.key});
 @override Widget build(BuildContext c)=>const Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.storefront,size:65),SizedBox(height:12),Text('ঊষা',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),Text('প্রকৃতির স্বাদ, ঘরে ঘরে'),SizedBox(height:10),Text('অর্ডার WhatsApp-এ পাঠানো হবে')]));
}
