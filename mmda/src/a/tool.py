import uuid

class Node:
    def __init__(self, state, event, action):
        self.id = state
        self.event = event
        self.action = action
        self.transitions = []

    def add_transition(self, target_node):
        self.transitions.append(target_node)

class FSTGenerator:
    def __init__(self):
        self.nodes = {}

    def add_node(self, state, event, action):
        node = Node(state, event, action)
        self.nodes[state] = node
        return node

    def add_transition(self, from_state, to_state):
        from_node = self.nodes.get(from_state)
        to_node = self.nodes.get(to_state)
        if from_node and to_node:
            from_node.add_transition(to_node)

    def generate_fst(self):
        lines = []
        for node in self.nodes.values():
            for target in node.transitions:
                line = f"{node.id}\t{target.id}\t{node.event}\t{target.action}"
                lines.append(line)
        return "\n".join(lines)
