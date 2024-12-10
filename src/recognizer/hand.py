import cv2
import mediapipe as mp
import numpy as np


class HandRecognizer:
    def __init__(self):
        self.mp_hands = mp.solutions.hands
        self.hands = self.mp_hands.Hands()
        self.mp_draw = mp.solutions.drawing_utils

    def is_finger_straight(self, landmarks, finger_ids):
        angles = [
            self.calculate_angle(landmarks[finger_ids[0]], landmarks[finger_ids[1]], landmarks[finger_ids[2]]),
            self.calculate_angle(landmarks[finger_ids[1]], landmarks[finger_ids[2]], landmarks[finger_ids[3]])
        ]
        thresholds = [160, 160]
        return all(angle > threshold for angle, threshold in zip(angles, thresholds))
    
    def calculate_angle(self, a, b, c):
        a = np.array([a.x, a.y])
        b = np.array([b.x, b.y])
        c = np.array([c.x, c.y])

        radians = np.arctan2(c[1]-b[1], c[0]-b[0]) - \
            np.arctan2(a[1]-b[1], a[0]-b[0])
        angle = np.abs(radians * 180.0 / np.pi)
        if angle > 180.0:
            angle = 360 - angle
        return angle

    def recognize_number(self, frame: cv2.VideoCapture) -> int:
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.hands.process(frame_rgb)
        if results.multi_hand_landmarks:
            for hand_landmarks in results.multi_hand_landmarks:
                self.mp_draw.draw_landmarks(
                    frame, hand_landmarks, self.mp_hands.HAND_CONNECTIONS)
                fingers = []
                finger_ids = [[4, 3, 2, 1], [8, 7, 6, 5], [12, 11, 10, 9],
                             [16, 15, 14, 13], [20, 19, 18, 17]]
                for ids in finger_ids:
                    if self.is_finger_straight(hand_landmarks.landmark, ids):
                        fingers.append(1)
                    else:
                        fingers.append(0)
                count = sum(fingers)
                return count
        return 0


if __name__ == "__main__":
    cap = cv2.VideoCapture(0)
    hand_recognizer = HandRecognizer()
    while True:
        ret, frame = cap.read()
        number = hand_recognizer.recognize_number(frame)
        cv2.putText(frame, str(number), (50, 50),
                    cv2.FONT_HERSHEY_SIMPLEX, 2, (0, 0, 255), 2, cv2.LINE_AA)
        cv2.imshow("frame", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    cap.release()
    cv2.destroyAllWindows()
