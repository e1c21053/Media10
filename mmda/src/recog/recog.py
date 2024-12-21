import cv2
import mediapipe as mp

class ExerciseRecognizer:
    def __init__(self):
        self.mp_pose = mp.solutions.pose
        self.pose = self.mp_pose.Pose()
        self.mp_drawing = mp.solutions.drawing_utils
        
        self.push_up_stage = None
        self.push_up_count = 0

    def recognize_exercise(self, frame: cv2.VideoCapture, mode: str) -> cv2.VideoCapture:
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.pose.process(frame_rgb)
        
        if results.pose_landmarks:
            self.mp_drawing.draw_landmarks(frame, results.pose_landmarks, self.mp_pose.POSE_CONNECTIONS)
        
        if mode == "push_ups":
            self.push_ups(results.pose_landmarks)
        
        
        return frame

        
    def push_ups(self, landmarks):
        if landmarks:
            # Get coordinates of shoulder, elbow, and wrist
            shoulder = landmarks.landmark[self.mp_pose.PoseLandmark.RIGHT_SHOULDER]
            elbow = landmarks.landmark[self.mp_pose.PoseLandmark.RIGHT_ELBOW]
            wrist = landmarks.landmark[self.mp_pose.PoseLandmark.RIGHT_WRIST]

            # Calculate angle at the elbow
            angle = self.calculate_angle(shoulder, elbow, wrist)
            print(f"Angle: {angle}")
            # Push-up detection logic
            if angle > 180:
                self.push_up_stage = "up"
            if angle < 90 and self.push_up_stage == "up":
                self.push_up_stage = "down"
                self.push_up_count += 1
                print(f"Push-up count: {self.push_up_count}")

    def calculate_angle(self, a, b, c):
        import numpy as np
        a = np.array([a.x, a.y])
        b = np.array([b.x, b.y])
        c = np.array([c.x, c.y])

        radians = np.arctan2(c[1]-b[1], c[0]-b[0]) - np.arctan2(a[1]-b[1], a[0]-b[0])
        angle = np.abs(radians * 180.0 / np.pi)
        if angle > 180.0:
            angle = 360 - angle
        return angle

    def sit_ups(self, landmarks):
        pass

    def arm_raises(self, landmarks):
        pass

def main():
    cap = cv2.VideoCapture(0)
    recognizer = ExerciseRecognizer()

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        mode = "push_ups"
        frame = recognizer.recognize_exercise(frame,mode)
        cv2.imshow('Exercise Recognition', frame)

        if cv2.waitKey(10) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
