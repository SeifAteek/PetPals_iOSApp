import os

directory = '/Users/seifateek/Downloads/PetPals/iOSapp/PetPals/PetPals'

replacements = {
    'struct Product': 'struct PetProduct',
    '[Product]': '[PetProduct]',
    '(product: Product)': '(product: PetProduct)',
    'let product: Product': 'let product: PetProduct',
    '-> [Product]': '-> [PetProduct]',
    '[Product: Int]': '[PetProduct: Int]',
    'struct Order:': 'struct ShopOrder:',
    '[Order]': '[ShopOrder]',
    '-> [Order]': '-> [ShopOrder]',
    'struct OrderItem': 'struct ShopOrderItem',
    '[OrderItem]': '[ShopOrderItem]',
    'struct Message:': 'struct ChatMessage:',
    '[Message]': '[ChatMessage]',
    '-> [Message]': '-> [ChatMessage]',
    'let message: Message': 'let message: ChatMessage',
    'AnyPublisher<Message': 'AnyPublisher<ChatMessage',
    'Subject<Message': 'Subject<ChatMessage',
    'decode(Message.self': 'decode(ChatMessage.self'
}

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.swift'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            
            new_content = content
            for old, new in replacements.items():
                new_content = new_content.replace(old, new)
                
            # For specific instantiations:
            new_content = new_content.replace(' Order(', ' ShopOrder(')
            new_content = new_content.replace(' OrderItem(', ' ShopOrderItem(')
            new_content = new_content.replace(' Message(', ' ChatMessage(')
            
            if content != new_content:
                with open(filepath, 'w') as f:
                    f.write(new_content)
                print(f"Updated {filepath}")
