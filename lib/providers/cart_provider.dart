import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
StateNotifier:
->  is a class used for managing a piece of data (the "state")
-> It provides a simple, performant way to notify listeners when the state changes, making it ideal for use with state management solutions like Riverpod. 

Ex:
You put an initial value in it.
It holds onto that value.
When the value needs to change, you replace the entire value inside the container.
It then taps everyone who is "listening" to it on the shoulder and says, "Hey, I have a new value!" 

-> It promotes an immutable approach, meaning you don't change the data directly, 
  but rather replace the old state with a new one whenever a change occurs. 
*/
class CartNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  CartNotifier() : super([]);

  void addToCart(Map<String, dynamic> item) {
    state = [...state, item];
  }

  void removeFromCart(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }

  void clearCart() => state = [];
}

final cartProvider = StateNotifierProvider<CartNotifier, List<Map<String, dynamic>>>((ref) {
  return CartNotifier();
});